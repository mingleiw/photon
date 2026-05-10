# photon — Entropie Fault Chain System

An end-to-end Kubernetes incident investigation system built on real eBPF flow capture.

## What it does

1. **Captures** live TCP flows from XDP-attached probes on service veth interfaces
2. **Builds** a causal fault graph — service-to-service edges come from observed traffic, not hardcoded rules
3. **Ranks** root-cause candidates by outbound causal weight
4. **Dispatches** autonomous agent teams (metrics, logs, topology, correlation, synthesis) per candidate
5. **Streams** findings back to the UI over SSE in real time

## Stack

| Service | Language | Role |
|---------|----------|------|
| `services/api` | Rust / Axum | REST + SSE API, causal graph, root scoring |
| `services/agent` | Rust / rig | NATS subscriber, orchestrator, LLM agent teams |
| `services/collector` | Rust | XDP flow reader → topology_edges (raw BPF syscalls, no kernel headers needed) |
| `services/ui` | TypeScript / React | Incident graph + heatmap + live investigation stream |
| PostgreSQL | — | Incidents, anomalies, topology_edges |
| NATS | — | investigation pub/sub |

## Quick start

```bash
cd entropie/ops
docker compose up postgres nats -d
cargo run -p entropie-api
```

Open `http://localhost:8080/api/incidents` — the demo checkout-degradation incident is pre-seeded.

For agent investigation (requires Ollama or any OpenAI-compatible endpoint):

```bash
NATS_URL=nats://localhost:4222 \
LLM_BASE_URL=http://localhost:11434/v1 \
LLM_MODEL=qwen2.5:0.5b \
cargo run -p entropie-agent
```

## eBPF collector

The collector reads the XDP `flow_map` directly via Linux BPF syscalls — no Aya, no libbpf, no kernel headers. It iterates map IDs, matches on key/value size, and upserts normalized edge weights to `topology_edges`. The graph API uses live edges when available, falling back to static rules only when the collector has no data.

See `entropie/` for full documentation.
