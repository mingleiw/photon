pub mod correlation;
pub mod logs;
pub mod metrics;
pub mod synthesis;
pub mod topology;

use anyhow::Result;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentInput {
    pub incident_id: String,
    pub entity_type: String,
    pub entity_id: String,
    pub metric: String,
    pub incident_start: String,
    pub incident_end: String,
    pub api_base_url: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentEvidence {
    pub source: String,
    pub summary: String,
    pub raw: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TeamFinding {
    pub entity_type: String,
    pub entity_id: String,
    pub summary: String,
    pub revised_confidence: f64,
    pub evidence: Vec<AgentEvidence>,
    pub proposed_fix: Option<ProposedFix>,
    pub done: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProposedFix {
    pub description: String,
    pub command: Option<String>,
    pub requires_approval: bool,
}
