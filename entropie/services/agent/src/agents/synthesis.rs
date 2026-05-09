use anyhow::Result;
use rig::{client::{CompletionClient, Nothing}, completion::Prompt, providers::ollama};
use serde_json::json;

use super::{AgentEvidence, AgentInput, ProposedFix, TeamFinding};

pub async fn run(
    input: &AgentInput,
    evidence: Vec<AgentEvidence>,
    model: &str,
    llm_base_url: &str,
    _api_key: &str,
) -> Result<TeamFinding> {
    let client = ollama::Client::builder()
        .api_key(Nothing)
        .base_url(llm_base_url)
        .build()
        .map_err(|e| anyhow::anyhow!("{e}"))?;

    let evidence_text: String = evidence
        .iter()
        .map(|e| format!("[{}] {}", e.source, e.summary))
        .collect::<Vec<_>>()
        .join("\n");

    let agent = client
        .agent(model)
        .preamble(
            "You are a synthesis agent for incident root-cause analysis. \
             Given evidence from multiple specialist agents, you produce:\n\
             1. A 3-5 sentence summary of the root cause\n\
             2. A revised confidence score (0.0-1.0) for this entity being the root cause\n\
             3. A proposed remediation command (kubectl or similar)\n\
             Respond ONLY with valid JSON matching this schema:\n\
             {\"summary\": string, \"revised_confidence\": number, \"proposed_fix\": {\"description\": string, \"command\": string | null}}"
        )
        .build();

    let prompt = format!(
        "Synthesize findings for {} '{}' (incident {}).\n\nEvidence:\n{}",
        input.entity_type, input.entity_id, input.incident_id, evidence_text
    );

    let raw = agent.prompt(&prompt).await?;

    let parsed: serde_json::Value = serde_json::from_str(&raw).unwrap_or_else(|_| {
        json!({
            "summary": raw,
            "revised_confidence": 0.5,
            "proposed_fix": null
        })
    });

    let summary = parsed["summary"].as_str().unwrap_or(&raw).to_string();
    let revised_confidence = parsed["revised_confidence"].as_f64().unwrap_or(0.5).clamp(0.0, 1.0);

    let proposed_fix = parsed["proposed_fix"].as_object().map(|fix| ProposedFix {
        description: fix.get("description").and_then(|v| v.as_str()).unwrap_or("").to_string(),
        command: fix.get("command").and_then(|v| v.as_str()).map(|s| s.to_string()),
        requires_approval: true,
    });

    Ok(TeamFinding {
        entity_type: input.entity_type.clone(),
        entity_id: input.entity_id.clone(),
        summary,
        revised_confidence,
        evidence,
        proposed_fix,
        done: true,
    })
}
