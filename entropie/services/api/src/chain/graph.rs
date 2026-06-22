use std::collections::HashMap;

use crate::model::{Anomaly, Graph, GraphEdge, GraphNode, TopologyEdge};

/// Build a causality graph from anomalies.
/// `live_edges`: eBPF-observed service-to-service flows from the collector.
///   When non-empty, service→service edges come from observed traffic.
///   Falls back to hardcoded dependency rules when the collector has no data.
pub fn build_graph(anomalies: &[Anomaly], live_edges: &[TopologyEdge]) -> Graph {
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

    // Infra pressure: node anomalies → all service anomalies (always applied)
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

    if !live_edges.is_empty() {
        // Use eBPF-observed flows for service→service edges
        for e in live_edges {
            let from = format!("service:{}", e.src_service);
            let to = format!("service:{}", e.dst_service);
            // Only add edge if both endpoints have anomalies in this incident
            if nodes.iter().any(|n| n.id == from) && nodes.iter().any(|n| n.id == to) {
                let edge_key = format!("{}->{}", from, to);
                edges
                    .entry(edge_key)
                    .and_modify(|ex| { if ex.weight < e.weight { ex.weight = e.weight; } })
                    .or_insert(GraphEdge {
                        from,
                        to,
                        weight: e.weight,
                        rationale: format!(
                            "eBPF-observed: {} TCP connections captured by XDP probe",
                            e.conn_count
                        ),
                    });
            }
        }
    } else {
        // Fallback: hardcoded payments → checkout dependency
        let payments_key = "service:payments/payments-api";
        let checkout_key = "service:checkout/checkout-api";
        let has_payments = nodes.iter().any(|n| n.id == payments_key);
        let has_checkout = nodes.iter().any(|n| n.id == checkout_key);
        if has_payments && has_checkout {
            let edge_key = format!("{}->{}", payments_key, checkout_key);
            edges
                .entry(edge_key)
                .and_modify(|e| { if e.weight < 0.75 { e.weight = 0.75; } })
                .or_insert(GraphEdge {
                    from: payments_key.into(),
                    to: checkout_key.into(),
                    weight: 0.75,
                    rationale: "Static dependency: checkout calls payments (no eBPF data)".into(),
                });
        }
    }

    let mut edges: Vec<GraphEdge> = edges.into_values().collect();
    edges.sort_by(|a, b| a.from.cmp(&b.from).then(a.to.cmp(&b.to)));

    Graph { nodes, edges }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;
    use uuid::Uuid;

    fn anomaly(entity_type: &str, entity_id: &str, severity: f64, confidence: f64) -> Anomaly {
        Anomaly {
            id: Uuid::new_v4(),
            incident_id: Uuid::new_v4(),
            ts: Utc::now(),
            entity_type: entity_type.into(),
            entity_id: entity_id.into(),
            metric: "test_metric".into(),
            severity,
            confidence,
            domain: None,
            details: None,
        }
    }

    #[test]
    fn node_to_service_edges_created() {
        let anomalies = vec![
            anomaly("node", "node-1", 0.7, 0.8),
            anomaly("service", "payments/payments-api", 0.8, 0.7),
        ];
        let graph = build_graph(&anomalies, &[]);
        assert_eq!(graph.edges.len(), 1);
        assert_eq!(graph.edges[0].from, "node:node-1");
        assert_eq!(graph.edges[0].to, "service:payments/payments-api");
        assert!((graph.edges[0].weight - 0.55).abs() < 1e-6);
    }

    #[test]
    fn payments_to_checkout_edge_added() {
        let anomalies = vec![
            anomaly("service", "payments/payments-api", 0.9, 0.75),
            anomaly("service", "checkout/checkout-api", 0.95, 0.8),
        ];
        let graph = build_graph(&anomalies, &[]);
        let edge = graph.edges.iter().find(|e| {
            e.from == "service:payments/payments-api"
                && e.to == "service:checkout/checkout-api"
        });
        assert!(edge.is_some(), "payments->checkout edge should exist");
        assert!((edge.unwrap().weight - 0.75).abs() < 1e-6);
    }

    #[test]
    fn node_weight_accumulates_across_anomalies() {
        let mut a1 = anomaly("service", "svc-a", 0.5, 0.5);
        let mut a2 = anomaly("service", "svc-a", 0.5, 0.5);
        a1.incident_id = Uuid::new_v4();
        a2.incident_id = a1.incident_id;
        let graph = build_graph(&[a1, a2], &[]);
        let node = graph.nodes.iter().find(|n| n.entity_id == "svc-a").unwrap();
        assert!((node.weight - 0.5).abs() < 1e-6, "weight = 0.25 + 0.25 = 0.5");
    }

    #[test]
    fn empty_anomalies_returns_empty_graph() {
        let graph = build_graph(&[], &[]);
        assert!(graph.nodes.is_empty());
        assert!(graph.edges.is_empty());
    }

    #[test]
    fn live_edges_used_when_present() {
        use crate::model::TopologyEdge;
        let anomalies = vec![
            anomaly("service", "payments/payments-api", 0.9, 0.75),
            anomaly("service", "checkout/checkout-api", 0.95, 0.8),
        ];
        let live = vec![TopologyEdge {
            src_service: "payments/payments-api".into(),
            dst_service: "checkout/checkout-api".into(),
            weight: 0.9,
            conn_count: 42,
        }];
        let graph = build_graph(&anomalies, &live);
        let edge = graph.edges.iter().find(|e| {
            e.from == "service:payments/payments-api"
                && e.to == "service:checkout/checkout-api"
        });
        assert!(edge.is_some(), "eBPF edge should exist");
        assert!((edge.unwrap().weight - 0.9).abs() < 1e-6);
        assert!(edge.unwrap().rationale.contains("eBPF-observed"));
    }
}
