# Fault Chain System — Architecture (MVP)

## Inputs (eBPF-first)
- Node-level telemetry (cpu pressure, cgroup throttling, tcp retransmits, dns failures)
- Service-level dependency evidence (Cilium + Hubble)
- Metrics stored in Prometheus

## Detection (rule-based)
Prometheus alert rules (thresholds/burn-rate/robust z-score) emit anomaly events.

## Chain inference
- Build a dependency graph from observed service-to-service communication (Hubble flows aggregated)
- Create directed edges between anomaly nodes based on:
  - dependency direction
  - temporal ordering
  - metric compatibility (e.g., upstream latency → downstream errors)
- Output:
  - root-cause candidate ranking
  - impact heat map (by namespace/service/domain tags)

## Components
- collector: deploy + config for Cilium/Hubble and metric export
- api: ingest anomalies + build/score chains
- ui: visualize chain + heat map
