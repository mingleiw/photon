package chain

import (
	"testing"
	"time"

	"photon-api/internal/model"
)

func TestEstimateCost(t *testing.T) {
	end := time.Unix(600, 0) // 10 minutes after start
	incident := model.Incident{
		ID:      "test-001",
		StartTs: time.Unix(0, 0),
		EndTs:   &end,
	}
	checkout := "checkout"
	payments := "payments"
	anoms := []model.Anomaly{
		{Severity: 0.8, Confidence: 0.7, Domain: &payments},
		{Severity: 0.9, Confidence: 0.75, Domain: &payments},
		{Severity: 0.95, Confidence: 0.8, Domain: &checkout},
		{Severity: 0.85, Confidence: 0.7, Domain: &checkout},
	}
	cost := EstimateCost(incident, anoms)

	if cost.IncidentID != "test-001" {
		t.Fatalf("wrong incident id")
	}
	if cost.DurationMin != 10.0 {
		t.Fatalf("expected 10 min duration, got %v", cost.DurationMin)
	}
	if cost.TotalUSD <= 0 {
		t.Fatalf("expected positive cost, got %v", cost.TotalUSD)
	}
	if len(cost.Breakdown) != 2 {
		t.Fatalf("expected 2 domain breakdown items, got %d", len(cost.Breakdown))
	}
	// checkout ($50/min) should cost more than payments ($30/min)
	if cost.Breakdown[0].Domain != "checkout" {
		t.Fatalf("expected checkout to have highest cost, got %s", cost.Breakdown[0].Domain)
	}
}

func TestEstimateCostUnknownDomain(t *testing.T) {
	end := time.Unix(60, 0)
	incident := model.Incident{ID: "x", StartTs: time.Unix(0, 0), EndTs: &end}
	anoms := []model.Anomaly{
		{Severity: 1.0, Confidence: 1.0},
	}
	cost := EstimateCost(incident, anoms)
	// unknown domain uses defaultRatePerMin = 5.0
	// 1 min * 5 $/min * 1.0 weight = 5.0
	if cost.TotalUSD != 5.0 {
		t.Fatalf("expected $5.00, got %v", cost.TotalUSD)
	}
}
