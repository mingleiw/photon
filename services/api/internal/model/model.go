package model

import "time"

type Incident struct {
	ID      string     `json:"id"`
	Title   string     `json:"title"`
	StartTs time.Time  `json:"startTs"`
	EndTs   *time.Time `json:"endTs,omitempty"`
}

type Anomaly struct {
	ID         string    `json:"id"`
	IncidentID string    `json:"incidentId"`
	Ts         time.Time `json:"ts"`
	EntityType string    `json:"entityType"` // service|node
	EntityID   string    `json:"entityId"`
	Metric     string    `json:"metric"`
	Severity   float64   `json:"severity"`
	Confidence float64   `json:"confidence"`
	Domain     *string   `json:"domain,omitempty"`
}

type RootCandidate struct {
	EntityType string  `json:"entityType"`
	EntityID   string  `json:"entityId"`
	Score      float64 `json:"score"`
	Rationale  string  `json:"rationale"`
}

type HeatCell struct {
	Domain string  `json:"domain"`
	Weight float64 `json:"weight"`
}
