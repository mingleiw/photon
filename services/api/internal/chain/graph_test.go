package chain

import (
	"testing"
	"time"

	"photon-api/internal/model"
)

func TestBuildGraphAddsDependencyEdge(t *testing.T) {
	anoms := []model.Anomaly{
		{ID: "1", Ts: time.Unix(1, 0), EntityType: "service", EntityID: "payments/payments-api", Severity: 1, Confidence: 1},
		{ID: "2", Ts: time.Unix(2, 0), EntityType: "service", EntityID: "checkout/checkout-api", Severity: 1, Confidence: 1},
	}
	g := BuildGraph(anoms)
	found := false
	for _, e := range g.Edges {
		if e.From == "service:payments/payments-api" && e.To == "service:checkout/checkout-api" {
			found = true
		}
	}
	if !found {
		t.Fatalf("expected payments->checkout edge")
	}
}
