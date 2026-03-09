package chain

import (
	"sort"

	"photon-api/internal/model"
)

// ScoreRoots is a deterministic MVP scoring function.
// Heuristic:
// - earlier anomalies are more likely causes
// - node anomalies get a small boost (often shared infra)
// - higher severity * confidence increases score
func ScoreRoots(anoms []model.Anomaly) []model.RootCandidate {
	type key struct{ t, id string }
	firstIdx := map[key]int{}
	score := map[key]float64{}

	for i, a := range anoms {
		k := key{a.EntityType, a.EntityID}
		if _, ok := firstIdx[k]; !ok {
			firstIdx[k] = i
		}
		boost := 1.0
		if a.EntityType == "node" {
			boost = 1.1
		}
		score[k] += a.Severity * a.Confidence * boost
	}

	var out []model.RootCandidate
	for k, s := range score {
		r := "High anomaly weight"
		if k.t == "node" {
			r = "Node-level anomaly often propagates"
		}
		out = append(out, model.RootCandidate{EntityType: k.t, EntityID: k.id, Score: s, Rationale: r})
	}

	sort.Slice(out, func(i, j int) bool {
		if out[i].Score == out[j].Score {
			return out[i].EntityID < out[j].EntityID
		}
		return out[i].Score > out[j].Score
	})

	// prefer earlier entities on ties by slight adjustment
	for i := range out {
		k := key{out[i].EntityType, out[i].EntityID}
		out[i].Score = out[i].Score + 0.0001*float64(1000-firstIdx[k])
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Score > out[j].Score })
	return out
}

func Heatmap(anoms []model.Anomaly) []model.HeatCell {
	m := map[string]float64{}
	for _, a := range anoms {
		d := "unknown"
		if a.Domain != nil && *a.Domain != "" {
			d = *a.Domain
		}
		m[d] += a.Severity * a.Confidence
	}
	out := make([]model.HeatCell, 0, len(m))
	for d, w := range m {
		out = append(out, model.HeatCell{Domain: d, Weight: w})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Weight > out[j].Weight })
	return out
}
