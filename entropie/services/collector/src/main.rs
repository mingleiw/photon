use anyhow::Result;
use std::collections::HashMap;
use tracing::{info, warn};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod bpf;
mod db;

/// IP → service name mapping (loaded from env or config)
fn build_ip_map() -> HashMap<u32, &'static str> {
    let mut m = HashMap::new();
    // Default: our mock pod IPs from the dev environment
    // 10.0.1.2 = payments-api, 10.0.2.2 = checkout-api
    m.insert(ip_to_u32(10, 0, 1, 2), "payments/payments-api");
    m.insert(ip_to_u32(10, 0, 2, 2), "checkout/checkout-api");
    m
}

const fn ip_to_u32(a: u8, b: u8, c: u8, d: u8) -> u32 {
    ((a as u32) << 24) | ((b as u32) << 16) | ((c as u32) << 8) | (d as u32)
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer())
        .init();

    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://entropie:entropie@localhost:5432/entropie".into());

    let poll_secs: u64 = std::env::var("POLL_INTERVAL_SECS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(15);

    info!("entropie-collector starting");
    info!("database_url={} poll_interval={}s", database_url, poll_secs);

    let pool = db::connect(&database_url).await?;
    info!("connected to postgres");

    let ip_map = build_ip_map();
    info!("ip_map: {} entries", ip_map.len());

    // Find the BPF flow_map (key_size=16, value_size=16)
    let map_fd = match bpf::find_flow_map() {
        Ok(fd) => {
            info!("found eBPF flow_map fd={}", fd);
            fd
        }
        Err(e) => {
            warn!("eBPF flow_map not found (is the XDP program attached?): {}", e);
            warn!("collector will retry every {}s", poll_secs);
            -1
        }
    };

    let mut interval = tokio::time::interval(
        std::time::Duration::from_secs(poll_secs),
    );

    loop {
        interval.tick().await;

        let current_fd = if map_fd < 0 {
            match bpf::find_flow_map() {
                Ok(fd) => { info!("eBPF flow_map fd={} (late attach)", fd); fd }
                Err(_) => { continue; }
            }
        } else {
            map_fd
        };

        match bpf::read_flows(current_fd) {
            Ok(flows) => {
                info!("read {} BPF flow entries", flows.len());
                let edges = aggregate_edges(&flows, &ip_map);
                if !edges.is_empty() {
                    if let Err(e) = db::upsert_edges(&pool, &edges).await {
                        warn!("db upsert error: {}", e);
                    } else {
                        info!("upserted {} topology edges", edges.len());
                        for (k, v) in &edges {
                            info!("  {} -> {} (weight={:.3} conn={})", k.0, k.1, v.0, v.1);
                        }
                    }
                }
            }
            Err(e) => warn!("bpf read error: {}", e),
        }
    }
}

/// Aggregate raw BPF flows into (src_service, dst_service) → (weight, conn_count)
fn aggregate_edges(
    flows: &[bpf::Flow],
    ip_map: &HashMap<u32, &'static str>,
) -> HashMap<(String, String), (f64, i64)> {
    let mut counts: HashMap<(String, String), i64> = HashMap::new();

    for f in flows {
        let src = ip_map.get(&f.src_ip).copied().unwrap_or("unknown");
        let dst = ip_map.get(&f.dst_ip).copied().unwrap_or("unknown");
        if src == "unknown" || dst == "unknown" { continue; }
        *counts.entry((src.to_string(), dst.to_string())).or_default() += f.packets as i64;
    }

    let max_count = counts.values().copied().max().unwrap_or(1);
    counts
        .into_iter()
        .map(|(k, c)| {
            let weight = (c as f64 / max_count as f64).clamp(0.1, 1.0);
            (k, (weight, c))
        })
        .collect()
}
