//! eBPF network flow collector — placeholder.
//!
//! Production implementation will use the Aya framework to attach XDP/TC programs
//! that capture pod-to-pod network flows from the Linux kernel, then publish
//! structured flow events to NATS for the API to ingest as anomaly signals.
//!
//! Requires: Linux 5.8+, CAP_BPF or CAP_SYS_ADMIN, runs as a DaemonSet.

use anyhow::Result;
use tracing::info;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer())
        .init();

    let nats_url = std::env::var("NATS_URL").unwrap_or_else(|_| "nats://localhost:4222".into());

    info!("entropie-collector starting (stub mode)");
    info!("nats_url={}", nats_url);
    info!("eBPF collector not yet implemented — use Prometheus alerts as anomaly source");

    // Block forever so the container stays up
    tokio::signal::ctrl_c().await?;
    Ok(())
}
