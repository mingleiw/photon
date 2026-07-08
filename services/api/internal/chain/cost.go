package chain

import (
	"sort"
	"time"

	"photon-api/internal/model"
)

// domainRates maps domain names to estimated cost per minute (USD).
// These represent revenue-at-risk based on domain criticality.
var domainRates = map[string]float64{
	"checkout": 50.0,
	"payments": 30.0,
	"infra":    10.0,
}

const defaultRatePerMin = 5.0

// EstimateCost calculates a weighted revenue-impact estimate for an incident.
// Cost per domain = duration_min * rate_per_min * avg(severity * confidence).
func EstimateCost(incident model.Incident, anoms []model.Anomaly) model.CostSummary {
	var durationMin float64
	if incident.EndTs != nil {
		durationMin = incident.EndTs.Sub(incident.StartTs).Minutes()
	} else {
		durationMin = time.Since(incident.StartTs).Minutes()
	}

	type accum struct {
		totalWeight float64
		count       int
	}
	byDomain := map[string]*accum{}
	for _, a := range anoms {
		d := "unknown"
		if a.Domain != nil && *a.Domain != "" {
			d = *a.Domain
		}
		if byDomain[d] == nil {
			byDomain[d] = &accum{}
		}
		byDomain[d].totalWeight += a.Severity * a.Confidence
		byDomain[d].count++
	}

	var breakdown []model.CostItem
	var total float64
	for d, acc := range byDomain {
		rate := defaultRatePerMin
		if r, ok := domainRates[d]; ok {
			rate = r
		}
		avgWeight := acc.totalWeight / float64(acc.count)
		est := durationMin * rate * avgWeight
		total += est
		breakdown = append(breakdown, model.CostItem{
			Domain:       d,
			RatePerMin:   rate,
			DurationMin:  durationMin,
			Weight:       avgWeight,
			EstimatedUSD: est,
		})
	}
	sort.Slice(breakdown, func(i, j int) bool {
		return breakdown[i].EstimatedUSD > breakdown[j].EstimatedUSD
	})

	return model.CostSummary{
		IncidentID:  incident.ID,
		DurationMin: durationMin,
		TotalUSD:    total,
		Breakdown:   breakdown,
	}
}
