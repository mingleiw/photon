package model

// Graph is a minimal dependency/fault-chain graph for demo & MVP.
// Nodes represent entities (service/node). Edges represent probable propagation.

type Graph struct {
	Nodes []GraphNode `json:"nodes"`
	Edges []GraphEdge `json:"edges"`
}

type GraphNode struct {
	ID         string  `json:"id"`         // unique node id (entityType:entityId)
	EntityType string  `json:"entityType"` // service|node
	EntityID   string  `json:"entityId"`
	Domain     *string `json:"domain,omitempty"`
	Weight     float64 `json:"weight"` // aggregated anomaly weight
}

type GraphEdge struct {
	From      string  `json:"from"`
	To        string  `json:"to"`
	Weight    float64 `json:"weight"`    // confidence-weighted strength
	Rationale string  `json:"rationale"` // short explanation
}
