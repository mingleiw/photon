use anyhow::Result;
use std::sync::Arc;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod chain;
mod db;
mod model;
mod server;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer())
        .init();

    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "postgres://entropie:entropie@localhost:5432/entropie".into());

    let nats_url = std::env::var("NATS_URL").unwrap_or_else(|_| "nats://localhost:4222".into());

    let port: u16 = std::env::var("PORT")
        .unwrap_or_else(|_| "8080".into())
        .parse()?;

    tracing::info!("connecting to postgres");
    let pool = db::connect(&database_url).await?;

    tracing::info!("running migrations");
    db::migrate(&pool).await?;

    let nats = match async_nats::connect(&nats_url).await {
        Ok(c) => {
            tracing::info!("connected to nats at {}", nats_url);
            Some(Arc::new(c))
        }
        Err(e) => {
            tracing::warn!("nats unavailable ({}): agent investigation disabled", e);
            None
        }
    };

    let state = server::AppState { pool, nats };

    let app = server::router(state);
    let addr = format!("0.0.0.0:{}", port);
    tracing::info!("listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(&addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
