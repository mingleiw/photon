use anyhow::Result;
use sqlx::{PgPool, postgres::PgPoolOptions};
use std::collections::HashMap;
use std::time::Duration;

pub async fn connect(database_url: &str) -> Result<PgPool> {
    let pool = PgPoolOptions::new()
        .max_connections(3)
        .acquire_timeout(Duration::from_secs(10))
        .connect(database_url)
        .await?;
    Ok(pool)
}

/// Upsert topology edges derived from live BPF flows.
/// edges: (src_service, dst_service) → (weight, conn_count)
pub async fn upsert_edges(
    pool: &PgPool,
    edges: &HashMap<(String, String), (f64, i64)>,
) -> Result<()> {
    for ((src, dst), (weight, conn)) in edges {
        sqlx::query(
            "INSERT INTO topology_edges (src_service, dst_service, weight, conn_count, updated_at)
             VALUES ($1, $2, $3, $4, NOW())
             ON CONFLICT (src_service, dst_service)
             DO UPDATE SET weight = $3, conn_count = $4, updated_at = NOW()",
        )
        .bind(src)
        .bind(dst)
        .bind(weight)
        .bind(conn)
        .execute(pool)
        .await?;
    }
    Ok(())
}
