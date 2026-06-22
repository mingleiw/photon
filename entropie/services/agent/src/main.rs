use anyhow::Result;
use futures::StreamExt;
use std::sync::Arc;
use tracing::info;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use uuid::Uuid;

mod agents;
mod orchestrator;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer())
        .init();

    let nats_url = std::env::var("NATS_URL").unwrap_or_else(|_| "nats://localhost:4222".into());
    let api_base_url = std::env::var("API_BASE_URL").unwrap_or_else(|_| "http://api:8080".into());
    let llm_base_url = std::env::var("LLM_BASE_URL").unwrap_or_else(|_| "http://ollama:11434/v1".into());
    let llm_model = std::env::var("LLM_MODEL").unwrap_or_else(|_| "llama3.1:8b".into());
    let llm_api_key = std::env::var("LLM_API_KEY").unwrap_or_else(|_| "ollama".into());

    info!("connecting to nats at {}", nats_url);
    let nats = Arc::new(async_nats::connect(&nats_url).await?);

    let orchestrator = Arc::new(orchestrator::Orchestrator {
        nats: nats.clone(),
        api_base_url,
        llm_base_url,
        llm_model,
        llm_api_key,
    });

    info!("subscribing to investigate.* topics");
    let mut sub = nats.subscribe("investigate.*").await?;

    while let Some(msg) = sub.next().await {
        let subject = msg.subject.clone();
        let incident_id_str = String::from_utf8_lossy(&msg.payload).to_string();

        info!("received investigation request on {}: {}", subject, incident_id_str);

        match Uuid::parse_str(&incident_id_str) {
            Ok(incident_id) => {
                let orch = orchestrator.clone();
                tokio::spawn(async move {
                    if let Err(e) = orch.run(incident_id).await {
                        tracing::error!("orchestrator error: {}", e);
                    }
                });
            }
            Err(e) => tracing::error!("invalid incident id '{}': {}", incident_id_str, e),
        }
    }

    Ok(())
}
