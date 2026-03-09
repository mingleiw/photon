# photon — Fault Chain System (eBPF-first MVP)

This repository is evolving from the original Photon prototype into an **end-to-end Fault Chain System**.

## MVP goals
- Ingest **eBPF-derived telemetry** (node + service level) from a single Kubernetes cluster
- Detect anomalies via **rule-based** methods
- Build **cross-service fault chains** (probabilistic causal graph)
- Rank root-cause candidates
- Render an impact heat map

## OSS-first stack (MVP)
- eBPF telemetry + service dependency evidence: **Cilium + Hubble**
- Metrics + rules: **Prometheus**
- Storage: **Postgres**
- UI: minimal web UI (graph + heatmap)

## Quick start (dev)
See `docs/dev.md` (local dev) or `docs/install.md` (Kubernetes install).
