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

type CostItem struct {
	Domain    string  `json:"domain"`
	RatePerMin float64 `json:"ratePerMin"`
	DurationMin float64 `json:"durationMin"`
	Weight    float64 `json:"weight"`
	EstimatedUSD float64 `json:"estimatedUSD"`
}

type CostSummary struct {
	IncidentID  string     `json:"incidentId"`
	DurationMin float64    `json:"durationMin"`
	TotalUSD    float64    `json:"totalUSD"`
	Breakdown   []CostItem `json:"breakdown"`
}
