package chain

import (
	"sort"

	"photon-api/internal/model"
)

func nodeKey(a model.Anomaly) string {
	return a.EntityType + ":" + a.EntityID
}

// BuildGraph builds a minimal directed graph from anomalies.
// MVP heuristic for demo data:
// - create a node per unique entity
// - add edges based on known propagation patterns:
//   node -> service (infra pressure impacts service)
//   payments -> checkout (dependency)
// Weighting is deterministic for demo.
func BuildGraph(anoms []model.Anomaly) model.Graph {
	// nodes
	m := map[string]*model.GraphNode{}
	for _, a := range anoms {
		k := nodeKey(a)
		n, ok := m[k]
		if !ok {
			cpy := a.Domain
			n = &model.GraphNode{ID: k, EntityType: a.EntityType, EntityID: a.EntityID, Domain: cpy}
			m[k] = n
		}
		n.Weight += a.Severity * a.Confidence
	}
	var nodes []model.GraphNode
	for _, n := range m {
		nodes = append(nodes, *n)
	}
	sort.Slice(nodes, func(i, j int) bool { return nodes[i].ID < nodes[j].ID })

	// Build edges from anomalies: heuristic rules.
	var edges []model.GraphEdge

	// edge helpers
	addEdge := func(from, to string, w float64, why string) {
		if from == to {
			return
		}
		edges = append(edges, model.GraphEdge{From: from, To: to, Weight: w, Rationale: why})
	}

	// Detect a node anomaly and connect to all services with anomalies in the incident window.
	var nodeIDs []string
	var serviceIDs []string
	for _, n := range nodes {
		if n.EntityType == "node" {
			nodeIDs = append(nodeIDs, n.ID)
		}
		if n.EntityType == "service" {
			serviceIDs = append(serviceIDs, n.ID)
		}
	}
	// node -> service edges
	for _, nid := range nodeIDs {
		for _, sid := range serviceIDs {
			addEdge(nid, sid, 0.55, "Infra pressure can degrade service performance")
		}
	}

	// service dependency demo: if we see both payments and checkout services, connect payments -> checkout.
	// (In real v1 this comes from Cilium/Hubble flows.)
	var payments, checkout string
	for _, sid := range serviceIDs {
		if sid == "service:payments/payments-api" {
			payments = sid
		}
		if sid == "service:checkout/checkout-api" {
			checkout = sid
		}
	}
	if payments != "" && checkout != "" {
		addEdge(payments, checkout, 0.75, "Observed dependency: checkout calls payments")
	}

	// Dedup edges (from+to)
	tmp := map[string]model.GraphEdge{}
	for _, e := range edges {
		k := e.From + "->" + e.To
		if cur, ok := tmp[k]; ok {
			cur.Weight = max(cur.Weight, e.Weight)
			if cur.Rationale == "" {
				cur.Rationale = e.Rationale
			}
			tmp[k] = cur
		} else {
			tmp[k] = e
		}
	}
	edges = edges[:0]
	for _, e := range tmp {
		edges = append(edges, e)
	}
	sort.Slice(edges, func(i, j int) bool {
		if edges[i].From == edges[j].From {
			return edges[i].To < edges[j].To
		}
		return edges[i].From < edges[j].From
	})

	return model.Graph{Nodes: nodes, Edges: edges}
}

func max(a, b float64) float64 {
	if a > b {
		return a
	}
	return b
}
