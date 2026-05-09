use std::collections::HashMap;

use crate::model::{Anomaly, HeatCell, RootCandidate};

pub fn score_roots(anomalies: &[Anomaly]) -> Vec<RootCandidate> {
    let mut scores: HashMap<(String, String), f64> = HashMap::new();

    let earliest = anomalies.iter().map(|a| a.ts).min();

    for a in anomalies {
        let key = (a.entity_type.clone(), a.entity_id.clone());
        let boost = if a.entity_type == "node" { 1.1 } else { 1.0 };
        // Small penalty for anomalies that appeared later than the earliest — earlier = more likely root cause
        let time_adj = earliest
            .map(|t| {
                let delta = (a.ts - t).num_milliseconds() as f64;
                delta * 0.0001
            })
            .unwrap_or(0.0);

        *scores.entry(key).or_default() += a.severity * a.confidence * boost - time_adj;
    }

    let mut candidates: Vec<RootCandidate> = scores
        .into_iter()
        .map(|((entity_type, entity_id), score)| {
            let rationale = if entity_type == "node" {
                format!(
                    "Node-level anomaly with infra-pressure boost; score={:.3}",
                    score
                )
            } else {
                format!("Service anomaly; score={:.3}", score)
            };
            RootCandidate {
                entity_type,
                entity_id,
                score,
                rationale,
            }
        })
        .collect();

    candidates.sort_by(|a, b| b.score.partial_cmp(&a.score).unwrap());
    candidates
}

pub fn heatmap(anomalies: &[Anomaly]) -> Vec<HeatCell> {
    let mut weights: HashMap<String, f64> = HashMap::new();

    for a in anomalies {
        let domain = a.domain.clone().unwrap_or_else(|| "unknown".into());
        *weights.entry(domain).or_default() += a.severity * a.confidence;
    }

    let mut cells: Vec<HeatCell> = weights
        .into_iter()
        .map(|(domain, weight)| HeatCell { domain, weight })
        .collect();

    cells.sort_by(|a, b| b.weight.partial_cmp(&a.weight).unwrap());
    cells
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::{Duration, Utc};
    use uuid::Uuid;

    fn anomaly(entity_type: &str, entity_id: &str, metric: &str, severity: f64, confidence: f64, domain: &str, offset_secs: i64) -> Anomaly {
        Anomaly {
            id: Uuid::new_v4(),
            incident_id: Uuid::new_v4(),
            ts: Utc::now() + Duration::seconds(offset_secs),
            entity_type: entity_type.into(),
            entity_id: entity_id.into(),
            metric: metric.into(),
            severity,
            confidence,
            domain: Some(domain.into()),
            details: None,
        }
    }

    #[test]
    fn node_ranks_first_due_to_boost() {
        let anomalies = vec![
            anomaly("node", "node-1", "cpu", 0.7, 0.8, "infra", 0),
            anomaly("service", "payments/payments-api", "retrans", 0.8, 0.7, "payments", 60),
            anomaly("service", "checkout/checkout-api", "5xx", 0.95, 0.8, "checkout", 120),
        ];
        let roots = score_roots(&anomalies);
        assert_eq!(roots[0].entity_type, "node", "node should be top root candidate");
    }

    #[test]
    fn higher_severity_confidence_ranks_higher() {
        let anomalies = vec![
            anomaly("service", "low-svc", "m", 0.3, 0.3, "d", 0),
            anomaly("service", "high-svc", "m", 0.9, 0.9, "d", 0),
        ];
        let roots = score_roots(&anomalies);
        assert_eq!(roots[0].entity_id, "high-svc");
    }

    #[test]
    fn heatmap_aggregates_by_domain() {
        let anomalies = vec![
            anomaly("service", "svc-a", "m", 0.5, 0.5, "payments", 0),
            anomaly("service", "svc-b", "m", 0.5, 0.5, "payments", 0),
            anomaly("service", "svc-c", "m", 0.5, 0.5, "checkout", 0),
        ];
        let cells = heatmap(&anomalies);
        let payments = cells.iter().find(|c| c.domain == "payments").unwrap();
        let checkout = cells.iter().find(|c| c.domain == "checkout").unwrap();
        assert!((payments.weight - 0.5).abs() < 1e-6, "payments = 0.25 + 0.25 = 0.5");
        assert!((checkout.weight - 0.25).abs() < 1e-6);
        assert!(cells[0].domain == "payments", "payments should rank first");
    }

    #[test]
    fn demo_scenario_node_is_root_cause() {
        // The seeded demo: node pressure -> payments latency -> checkout errors
        let anomalies = vec![
            anomaly("node",    "node-1",                "node_cpu", 0.7,  0.8,  "infra",    0),
            anomaly("service", "payments/payments-api", "retrans",  0.8,  0.7,  "payments", 60),
            anomaly("service", "payments/payments-api", "latency",  0.9,  0.75, "payments", 120),
            anomaly("service", "checkout/checkout-api", "5xx",      0.95, 0.8,  "checkout", 180),
            anomaly("service", "checkout/checkout-api", "slo",      0.85, 0.7,  "checkout", 240),
        ];
        let roots = score_roots(&anomalies);
        assert_eq!(roots[0].entity_type, "node", "node-1 should be top root cause in demo scenario");
        assert_eq!(roots[0].entity_id, "node-1");
    }
}
