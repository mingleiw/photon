use std::collections::HashMap;

use crate::model::{Anomaly, Graph, GraphEdge, GraphNode};

pub fn build_graph(anomalies: &[Anomaly]) -> Graph {
    let mut node_map: HashMap<String, GraphNode> = HashMap::new();

    for a in anomalies {
        let key = format!("{}:{}", a.entity_type, a.entity_id);
        let node = node_map.entry(key.clone()).or_insert(GraphNode {
            id: key,
            entity_type: a.entity_type.clone(),
            entity_id: a.entity_id.clone(),
            domain: a.domain.clone(),
            weight: 0.0,
        });
        node.weight += a.severity * a.confidence;
    }

    let mut nodes: Vec<GraphNode> = node_map.into_values().collect();
    nodes.sort_by(|a, b| a.id.cmp(&b.id));

    let mut edges: HashMap<String, GraphEdge> = HashMap::new();

    let service_nodes: Vec<&GraphNode> = nodes.iter().filter(|n| n.entity_type == "service").collect();
    let node_nodes: Vec<&GraphNode> = nodes.iter().filter(|n| n.entity_type == "node").collect();

    // Infra pressure: node anomalies propagate to all service anomalies
    for infra in &node_nodes {
        for svc in &service_nodes {
            let edge_key = format!("{}->{}", infra.id, svc.id);
            edges.entry(edge_key).or_insert(GraphEdge {
                from: infra.id.clone(),
                to: svc.id.clone(),
                weight: 0.55,
                rationale: "Infra pressure can degrade service performance".into(),
            });
        }
    }

    // Known dependency: payments -> checkout (replaced by eBPF flows in production)
    let payments_key = "service:payments/payments-api";
    let checkout_key = "service:checkout/checkout-api";
    let has_payments = nodes.iter().any(|n| n.id == payments_key);
    let has_checkout = nodes.iter().any(|n| n.id == checkout_key);
    if has_payments && has_checkout {
        let edge_key = format!("{}->{}", payments_key, checkout_key);
        edges
            .entry(edge_key)
            .and_modify(|e| {
                if e.weight < 0.75 {
                    e.weight = 0.75;
                }
            })
            .or_insert(GraphEdge {
                from: payments_key.into(),
                to: checkout_key.into(),
                weight: 0.75,
                rationale: "Observed dependency: checkout calls payments".into(),
            });
    }

    let mut edges: Vec<GraphEdge> = edges.into_values().collect();
    edges.sort_by(|a, b| a.from.cmp(&b.from).then(a.to.cmp(&b.to)));

    Graph { nodes, edges }
}
