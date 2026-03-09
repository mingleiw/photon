package chain

import (
	"testing"
	"time"

	"photon-api/internal/model"
)

func TestScoreRootsDeterministic(t *testing.T) {
	anoms := []model.Anomaly{
		{ID: "1", Ts: time.Unix(1, 0), EntityType: "service", EntityID: "a", Severity: 1, Confidence: 1},
		{ID: "2", Ts: time.Unix(2, 0), EntityType: "node", EntityID: "n1", Severity: 0.5, Confidence: 1},
		{ID: "3", Ts: time.Unix(3, 0), EntityType: "service", EntityID: "a", Severity: 0.5, Confidence: 1},
	}
	roots := ScoreRoots(anoms)
	if len(roots) == 0 {
		t.Fatalf("expected roots")
	}
	if roots[0].EntityID != "a" {
		t.Fatalf("expected top root 'a', got %s", roots[0].EntityID)
	}
}

func TestHeatmap(t *testing.T) {
	d1 := "checkout"
	anoms := []model.Anomaly{{Domain: &d1, Severity: 1, Confidence: 0.5}}
	h := Heatmap(anoms)
	if len(h) != 1 || h[0].Domain != "checkout" {
		t.Fatalf("unexpected heatmap")
	}
}
