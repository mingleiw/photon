use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct Incident {
    pub id: Uuid,
    pub title: String,
    pub start_ts: DateTime<Utc>,
    pub end_ts: Option<DateTime<Utc>>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct Anomaly {
    pub id: Uuid,
    pub incident_id: Uuid,
    pub ts: DateTime<Utc>,
    pub entity_type: String,
    pub entity_id: String,
    pub metric: String,
    pub severity: f64,
    pub confidence: f64,
    pub domain: Option<String>,
    pub details: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RootCandidate {
    pub entity_type: String,
    pub entity_id: String,
    pub score: f64,
    pub rationale: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HeatCell {
    pub domain: String,
    pub weight: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GraphNode {
    pub id: String,
    pub entity_type: String,
    pub entity_id: String,
    pub domain: Option<String>,
    pub weight: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GraphEdge {
    pub from: String,
    pub to: String,
    pub weight: f64,
    pub rationale: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Graph {
    pub nodes: Vec<GraphNode>,
    pub edges: Vec<GraphEdge>,
}

/// Live topology edge from eBPF flow capture, stored in `topology_edges` table.
#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct TopologyEdge {
    pub src_service: String,
    pub dst_service: String,
    pub weight: f64,
    pub conn_count: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Finding {
    pub incident_id: Uuid,
    pub entity_type: String,
    pub entity_id: String,
    pub summary: String,
    pub revised_confidence: f64,
    pub evidence: Vec<String>,
    pub proposed_fix: Option<ProposedFix>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProposedFix {
    pub description: String,
    pub command: Option<String>,
    pub requires_approval: bool,
}
