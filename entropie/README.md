# Entropie

> Find the root cause before entropy finds you.

Entropie is an open-source Kubernetes incident investigation system. It captures live eBPF network flows from your cluster, infers causal fault chains across services, ranks root-cause candidates, and dispatches autonomous agent teams to investigate each hypothesis — surfacing evidence, revised confidence scores, and human-gated remediation proposals in real time.

## Differentiators

- **eBPF-first, zero instrumentation** — service topology discovered from live XDP flow capture, no SDKs or sidecars required
- **No kernel headers** — collector reads BPF maps via raw Linux syscalls; works in any container with `CAP_BPF`
- **Multi-agent investigation** — metrics, logs, topology, correlation, and synthesis agents fan out in parallel per root-cause candidate
- **Bring your own model** — any OpenAI-compatible LLM (Ollama, vLLM, Together.ai, Claude)
- **Open source** — Apache 2.0

## Stack

| Service | Language | Framework |
|---------|----------|-----------|
| `services/api` | Rust | Axum + sqlx + PostgreSQL |
| `services/agent` | Rust | rig + async-nats |
| `services/collector` | Rust | raw BPF syscalls (no Aya / libbpf dependency) |
| `services/ui` | TypeScript | React + Vite |
| Messaging | — | NATS |

## Architecture

```
XDP probes (veth interfaces)
      │  capture_flows BPF prog
      ▼
 flow_map (BPF hash map)
      │  polled every N seconds
      ▼
entropie-collector
      │  normalised edges → topology_edges (Postgres)
      ▼
entropie-api
      │  /api/incidents/{id}/graph  ← live edges when available
      │  /api/incidents/{id}/roots  ← causal weight ranking
      │  /api/incidents/{id}/investigate  ← SSE stream
      │
      │  publishes investigate.{id} → NATS
      ▼
entropie-agent
      │  orchestrator fans out by score gap
      │  MetricsAgent · LogsAgent · TopologyAgent
      │  CorrelationAgent · SynthesisAgent
      │  publishes findings.{id}.{entity} → NATS
      ▼
React UI  (graph + heatmap + live stream)
```

## Causal chain algorithm

1. **Detect** anomalies (severity × confidence weight per entity)
2. **Discover** topology from eBPF flows in `topology_edges`; fall back to static rules only when the collector has no data
3. **Add infra pressure** — node anomalies connect to all service anomalies (weight 0.55)
4. **Score edges** — flow weight (0–1) from normalised connection count
5. **Rank** root candidates by outbound causal weight + node-type boost
6. **Investigate** top-N candidates (score-gap threshold) with parallel agent teams

## Quick start (local demo)

```bash
cd ops
docker compose up postgres nats -d
```

```bash
# API
DATABASE_URL=postgres://entropie:entropie@localhost:5432/entropie \
RUST_LOG=info \
cargo run -p entropie-api
```

Open `http://localhost:8080/api/incidents` — a demo checkout-degradation incident is pre-seeded.

### Agent investigation (requires Ollama or any OpenAI-compatible endpoint)

```bash
NATS_URL=nats://localhost:4222 \
API_BASE_URL=http://localhost:8080 \
LLM_BASE_URL=http://localhost:11434/v1 \
LLM_MODEL=qwen2.5:0.5b \
LLM_API_KEY=ollama \
RUST_LOG=info \
cargo run -p entropie-agent
```

Then trigger investigation:

```bash
curl -N http://localhost:8080/api/incidents/<id>/investigate
```

### eBPF collector (requires XDP-attached flow_map)

Attach the XDP program to your service veth interfaces:

```bash
clang -O2 -target bpf -c flow_xdp.bpf.c -o flow_xdp.bpf.o
ip link set dev <veth> xdpgeneric obj flow_xdp.bpf.o sec xdp
```

Run the collector:

```bash
DATABASE_URL=postgres://entropie:entropie@localhost:5432/entropie \
POLL_INTERVAL_SECS=15 \
RUST_LOG=info \
cargo run -p entropie-collector
```

The collector finds the `flow_map` by scanning all BPF map IDs (key_size=16, value_size=16), reads all flow entries, and upserts normalised edges to `topology_edges`. The graph API switches to live edges automatically.

## Validation

```bash
# Unit tests (9 tests — graph, scoring, heatmap)
cargo test -p entropie-api

# Check live topology edges
curl http://localhost:8080/api/incidents/<id>/graph | jq '.edges[] | select(.rationale | startswith("eBPF"))'
```

## License

Apache 2.0
