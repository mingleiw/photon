use anyhow::Result;
use rig::{client::{CompletionClient, Nothing}, completion::Prompt, completion::ToolDefinition, providers::ollama, tool::Tool};
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::process::Command;

use super::{AgentEvidence, AgentInput};

#[derive(Debug, thiserror::Error)]
#[error("kubectl describe error: {0}")]
pub struct KubectlDescribeError(String);

#[derive(Deserialize, Serialize)]
pub struct KubectlDescribeArgs {
    pub resource: String,
    pub namespace: String,
    pub name: String,
}

pub struct KubectlDescribeTool;

impl Tool for KubectlDescribeTool {
    const NAME: &'static str = "kubectl_describe";
    type Error = KubectlDescribeError;
    type Args = KubectlDescribeArgs;
    type Output = String;

    async fn definition(&self, _prompt: String) -> ToolDefinition {
        ToolDefinition {
            name: Self::NAME.into(),
            description: "Describe a Kubernetes resource (read-only). Use to check resource limits, events, and status.".into(),
            parameters: json!({
                "type": "object",
                "properties": {
                    "resource": {"type": "string", "description": "Resource type: pod, deployment, node, service"},
                    "namespace": {"type": "string"},
                    "name": {"type": "string", "description": "Resource name or label selector"}
                },
                "required": ["resource", "namespace", "name"]
            }),
        }
    }

    async fn call(&self, args: Self::Args) -> Result<Self::Output, Self::Error> {
        let output = Command::new("kubectl")
            .args([
                "describe",
                &args.resource,
                &args.name,
                "-n", &args.namespace,
            ])
            .output()
            .map_err(|e| KubectlDescribeError(e.to_string()))?;
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
            "You are a Kubernetes topology agent. Check the deployment state, resource limits, \
             and recent events for {} '{}'. Look for OOMKills, pending pods, resource pressure, \
             or recent restarts. Return a concise 2-3 sentence summary.",
            input.entity_type, input.entity_id
        ))
        .tool(KubectlDescribeTool)
        .build();

    let parts: Vec<&str> = input.entity_id.splitn(2, '/').collect();
    let (namespace, name) = if parts.len() == 2 {
        (parts[0], parts[1])
    } else {
        ("default", input.entity_id.as_str())
    };

    let prompt = format!(
        "Check the topology and state of {} '{}' in namespace '{}'. \
         Look for resource pressure, OOMKills, or abnormal events that explain the {} anomaly.",
        input.entity_type, name, namespace, input.metric
    );

    let summary = agent.prompt(&prompt).await?;

    Ok(AgentEvidence {
        source: "topology".into(),
        summary,
        raw: json!({}),
    })
}
