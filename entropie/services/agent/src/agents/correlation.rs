use anyhow::Result;
use rig::{client::{CompletionClient, Nothing}, completion::Prompt, completion::ToolDefinition, providers::ollama, tool::Tool};
use serde::{Deserialize, Serialize};
use serde_json::json;

use super::{AgentEvidence, AgentInput};

#[derive(Debug, thiserror::Error)]
#[error("graph fetch error: {0}")]
pub struct GraphFetchError(String);

#[derive(Deserialize, Serialize)]
pub struct FetchGraphArgs {
    pub incident_id: String,
}

pub struct FetchGraphTool {
    pub api_base_url: String,
}

impl Tool for FetchGraphTool {
    const NAME: &'static str = "fetch_fault_graph";
    type Error = GraphFetchError;
    type Args = FetchGraphArgs;
    type Output = serde_json::Value;

    async fn definition(&self, _prompt: String) -> ToolDefinition {
        ToolDefinition {
            name: Self::NAME.into(),
            description: "Fetch the fault propagation graph for an incident from the Entropie API.".into(),
            parameters: json!({
                "type": "object",
                "properties": {
                    "incident_id": {"type": "string"}
                },
                "required": ["incident_id"]
            }),
        }
    }

    async fn call(&self, args: Self::Args) -> Result<Self::Output, Self::Error> {
        let url = format!("{}/api/incidents/{}/graph", self.api_base_url, args.incident_id);
        reqwest::get(&url)
            .await
            .map_err(|e| GraphFetchError(e.to_string()))?
            .json::<serde_json::Value>()
            .await
            .map_err(|e| GraphFetchError(e.to_string()))
    }
}

pub async fn run(input: &AgentInput, model: &str, llm_base_url: &str, _api_key: &str) -> Result<AgentEvidence> {
    let client = ollama::Client::builder()
        .api_key(Nothing)
        .base_url(llm_base_url)
        .build()
        .map_err(|e| anyhow::anyhow!("{e}"))?;

    let agent = client
        .agent(model)
        .preamble(&format!(
            "You are a correlation agent. You analyze the fault propagation graph to understand \
             how {} '{}' is connected to other anomalous entities. Identify upstream causes \
             and downstream impacts. Return a concise 2-3 sentence summary.",
            input.entity_type, input.entity_id
        ))
        .tool(FetchGraphTool { api_base_url: input.api_base_url.clone() })
        .build();

    let prompt = format!(
        "Fetch the fault graph for incident {} and analyze the edges connected to {} '{}'. \
         Which entities are upstream (potential causes) and which are downstream (impacted by this entity)?",
        input.incident_id, input.entity_type, input.entity_id
    );

    let summary = agent.prompt(&prompt).await?;

    Ok(AgentEvidence {
        source: "correlation".into(),
        summary,
        raw: json!({}),
    })
}
