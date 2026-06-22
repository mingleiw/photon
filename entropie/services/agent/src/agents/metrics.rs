use anyhow::Result;
use rig::{client::{CompletionClient, Nothing}, completion::Prompt, completion::ToolDefinition, providers::ollama, tool::Tool};
use serde::{Deserialize, Serialize};
use serde_json::json;

use super::{AgentEvidence, AgentInput};

#[derive(Debug, thiserror::Error)]
#[error("prometheus tool error: {0}")]
pub struct PrometheusToolError(String);

#[derive(Deserialize, Serialize)]
pub struct PrometheusQueryArgs {
    pub query: String,
    pub start: String,
    pub end: String,
}

pub struct PrometheusQueryTool {
    pub base_url: String,
}

impl Tool for PrometheusQueryTool {
    const NAME: &'static str = "prometheus_query";
    type Error = PrometheusToolError;
    type Args = PrometheusQueryArgs;
    type Output = serde_json::Value;

    async fn definition(&self, _prompt: String) -> ToolDefinition {
        ToolDefinition {
            name: Self::NAME.into(),
            description: "Query Prometheus for metric data in a time range. Use PromQL.".into(),
            parameters: json!({
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "PromQL query"},
                    "start": {"type": "string", "description": "RFC3339 start time"},
                    "end": {"type": "string", "description": "RFC3339 end time"}
                },
                "required": ["query", "start", "end"]
            }),
        }
    }

    async fn call(&self, args: Self::Args) -> Result<Self::Output, Self::Error> {
        let client = reqwest::Client::new();
        client
            .get(format!("{}/api/v1/query_range", self.base_url))
            .query(&[
                ("query", args.query.as_str()),
                ("start", args.start.as_str()),
                ("end", args.end.as_str()),
                ("step", "15s"),
            ])
            .send()
            .await
            .map_err(|e| PrometheusToolError(e.to_string()))?
            .json::<serde_json::Value>()
            .await
            .map_err(|e| PrometheusToolError(e.to_string()))
    }
}

pub async fn run(input: &AgentInput, model: &str, llm_base_url: &str, _api_key: &str) -> Result<AgentEvidence> {
    let prometheus_url = std::env::var("PROMETHEUS_URL")
        .unwrap_or_else(|_| "http://prometheus:9090".into());

    let client = ollama::Client::builder()
        .api_key(Nothing)
        .base_url(llm_base_url)
        .build()
        .map_err(|e| anyhow::anyhow!("{e}"))?;

    let agent = client
        .agent(model)
        .preamble(&format!(
            "You are a metrics analysis agent investigating why {} {} is anomalous \
             during incident {} (from {} to {}). Query Prometheus to gather evidence. \
             Return a concise 2-3 sentence summary of what the metrics show.",
            input.entity_type, input.entity_id, input.incident_id,
            input.incident_start, input.incident_end
        ))
        .tool(PrometheusQueryTool { base_url: prometheus_url })
        .build();

    let prompt = format!(
        "Investigate the metric '{}' for {} '{}' between {} and {}. \
         Query related metrics to understand the anomaly. Summarize your findings.",
        input.metric, input.entity_type, input.entity_id,
        input.incident_start, input.incident_end
    );

    let summary = agent.prompt(&prompt).await?;

    Ok(AgentEvidence {
        source: "metrics".into(),
        summary,
        raw: json!({}),
    })
}
