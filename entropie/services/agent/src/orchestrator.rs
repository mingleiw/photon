use anyhow::Result;
use std::sync::Arc;
use tokio::task::JoinSet;
use tracing::{error, info};
use uuid::Uuid;

use crate::agents::{AgentInput, TeamFinding};

const SCORE_GAP_THRESHOLD: f64 = 0.3;
const MAX_PARALLEL_TEAMS: usize = 3;

#[derive(Debug, Clone, serde::Deserialize)]
struct RootCandidate {
    entity_type: String,
    entity_id: String,
    score: f64,
    #[allow(dead_code)]
    rationale: String,
}

pub struct Orchestrator {
    pub nats: Arc<async_nats::Client>,
    pub api_base_url: String,
    pub llm_base_url: String,
    pub llm_model: String,
    pub llm_api_key: String,
}

impl Orchestrator {
    pub async fn run(&self, incident_id: Uuid) -> Result<()> {
        info!("starting investigation for incident {}", incident_id);

        // Fetch ranked root candidates from the API
        let url = format!("{}/api/incidents/{}/roots", self.api_base_url, incident_id);
        let candidates: Vec<RootCandidate> = reqwest::get(&url).await?.json().await?;

        if candidates.is_empty() {
            info!("no root candidates for incident {}", incident_id);
            return Ok(());
        }

        // Fan out to top-N candidates within score gap
        let top_score = candidates[0].score;
        let targets: Vec<&RootCandidate> = candidates
            .iter()
            .take(MAX_PARALLEL_TEAMS)
            .take_while(|c| top_score - c.score <= SCORE_GAP_THRESHOLD)
            .collect();

        info!(
            "investigating {} root candidates for incident {}",
            targets.len(),
            incident_id
        );

        // Fetch representative anomaly for each candidate to get metric/time info
        let anomalies_url = format!("{}/api/incidents/{}/anomalies", self.api_base_url, incident_id);
        let anomalies: Vec<serde_json::Value> = reqwest::get(&anomalies_url).await?.json().await?;

        let mut tasks = JoinSet::new();

        for candidate in targets {
            // Find the most severe anomaly for this candidate
            let anomaly = anomalies
                .iter()
                .filter(|a| {
                    a["entity_type"].as_str() == Some(&candidate.entity_type)
                        && a["entity_id"].as_str() == Some(&candidate.entity_id)
                })
                .max_by(|a, b| {
                    a["severity"]
                        .as_f64()
                        .unwrap_or(0.0)
                        .partial_cmp(&b["severity"].as_f64().unwrap_or(0.0))
                        .unwrap()
                });

            let (metric, start, end) = anomaly
                .map(|a| {
                    (
                        a["metric"].as_str().unwrap_or("unknown").to_string(),
                        a["ts"].as_str().unwrap_or("").to_string(),
                        a["ts"].as_str().unwrap_or("").to_string(),
                    )
                })
                .unwrap_or_else(|| ("unknown".into(), "".into(), "".into()));

            let input = AgentInput {
                incident_id: incident_id.to_string(),
                entity_type: candidate.entity_type.clone(),
                entity_id: candidate.entity_id.clone(),
                metric,
                incident_start: start,
                incident_end: end,
                api_base_url: self.api_base_url.clone(),
            };

            let nats = self.nats.clone();
            let model = self.llm_model.clone();
            let llm_base = self.llm_base_url.clone();
            let api_key = self.llm_api_key.clone();

            tasks.spawn(async move {
                match investigate_team(input, &model, &llm_base, &api_key).await {
                    Ok(finding) => {
                        let subject = format!("findings.{}.{}", incident_id, finding.entity_id.replace('/', "."));
                        let payload = serde_json::to_vec(&finding).unwrap_or_default();
                        let _ = nats.publish(subject, payload.into()).await;
                        Ok(finding)
                    }
                    Err(e) => Err(e),
                }
            });
        }

        while let Some(result) = tasks.join_next().await {
            match result {
                Ok(Ok(finding)) => info!("completed investigation for {}", finding.entity_id),
                Ok(Err(e)) => error!("investigation error: {}", e),
                Err(e) => error!("task error: {}", e),
            }
        }

        // Publish done sentinel
        let done = serde_json::json!({"incident_id": incident_id.to_string(), "done": true});
        let subject = format!("findings.{}.done", incident_id);
        let _ = self.nats.publish(subject, serde_json::to_vec(&done).unwrap_or_default().into()).await;

        info!("investigation complete for incident {}", incident_id);
        Ok(())
    }
}

async fn investigate_team(
    input: AgentInput,
    model: &str,
    llm_base_url: &str,
    api_key: &str,
) -> Result<TeamFinding> {
    use crate::agents::{correlation, logs, metrics, synthesis, topology};

    // Run specialist agents in parallel
    let (metrics_ev, logs_ev, topology_ev, correlation_ev) = tokio::join!(
        metrics::run(&input, model, llm_base_url, api_key),
        logs::run(&input, model, llm_base_url, api_key),
        topology::run(&input, model, llm_base_url, api_key),
        correlation::run(&input, model, llm_base_url, api_key),
    );

    let evidence: Vec<_> = [metrics_ev, logs_ev, topology_ev, correlation_ev]
        .into_iter()
        .filter_map(|r| r.ok())
        .collect();

    synthesis::run(&input, evidence, model, llm_base_url, api_key).await
}
