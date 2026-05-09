use anyhow::Result;
use rig::{client::{CompletionClient, Nothing}, completion::Prompt, completion::ToolDefinition, providers::ollama, tool::Tool};
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::process::Command;

use super::{AgentEvidence, AgentInput};

#[derive(Debug, thiserror::Error)]
#[error("kubectl logs error: {0}")]
pub struct KubectlLogsError(String);

#[derive(Deserialize, Serialize)]
pub struct KubectlLogsArgs {
    pub namespace: String,
    pub pod_selector: String,
    pub since: String,
    pub tail: Option<u32>,
}

pub struct KubectlLogsTool;

impl Tool for KubectlLogsTool {
    const NAME: &'static str = "kubectl_logs";
    type Error = KubectlLogsError;
    type Args = KubectlLogsArgs;
    type Output = String;

    async fn definition(&self, _prompt: String) -> ToolDefinition {
        ToolDefinition {
            name: Self::NAME.into(),
            description: "Read pod logs from Kubernetes (read-only). Returns recent log lines.".into(),
            parameters: json!({
                "type": "object",
                "properties": {
                    "namespace": {"type": "string"},
                    "pod_selector": {"type": "string", "description": "Label selector e.g. app=payments-api"},
                    "since": {"type": "string", "description": "Duration string e.g. 10m, 1h"},
                    "tail": {"type": "integer", "description": "Number of lines, default 100"}
                },
                "required": ["namespace", "pod_selector", "since"]
            }),
        }
    }

    async fn call(&self, args: Self::Args) -> Result<Self::Output, Self::Error> {
        let tail = args.tail.unwrap_or(100).to_string();
        let output = Command::new("kubectl")
            .args([
                "logs",
                "-n", &args.namespace,
                "-l", &args.pod_selector,
                "--since", &args.since,
                "--tail", &tail,
            ])
            .output()
            .map_err(|e| KubectlLogsError(e.to_string()))?;
        Ok(String::from_utf8_lossy(&output.stdout).to_string())
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
            "You are a log analysis agent. Investigate why {} '{}' is showing anomalies. \
             Read pod logs to find errors, exceptions, or warnings. \
             Return a concise 2-3 sentence summary of what the logs show.",
            input.entity_type, input.entity_id
        ))
        .tool(KubectlLogsTool)
        .build();

    let parts: Vec<&str> = input.entity_id.splitn(2, '/').collect();
    let (namespace, name) = if parts.len() == 2 {
        (parts[0], parts[1])
    } else {
        ("default", input.entity_id.as_str())
    };

    let prompt = format!(
        "Read logs for {} in namespace {} since the incident started at {}. \
         Look for errors or warnings related to {}. Summarize what you find.",
        name, namespace, input.incident_start, input.metric
    );

    let summary = agent.prompt(&prompt).await?;

    Ok(AgentEvidence {
        source: "logs".into(),
        summary,
        raw: json!({}),
    })
}
