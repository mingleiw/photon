use std::collections::HashMap;

use crate::model::{Anomaly, HeatCell, RootCandidate};

pub fn score_roots(anomalies: &[Anomaly]) -> Vec<RootCandidate> {
    let mut scores: HashMap<(String, String), f64> = HashMap::new();

    let earliest = anomalies.iter().map(|a| a.ts).min();

    for a in anomalies {
        let key = (a.entity_type.clone(), a.entity_id.clone());
        let boost = if a.entity_type == "node" { 1.1 } else { 1.0 };
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
