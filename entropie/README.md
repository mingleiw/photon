# Entropie

> Find the root cause before entropy finds you.

Entropie is an open-source Kubernetes incident investigation system. It ingests eBPF network flows from your cluster, automatically infers causal fault chains across services, ranks root-cause candidates, and dispatches autonomous agent teams to deep-dive each hypothesis — surfacing evidence, revised confidence scores, and human-gated remediation proposals in real time.

## Differentiators

- **eBPF-first, zero instrumentation** — service topology discovered from live network flows (Cilium/Hubble), no SDKs required
- **Multi-agent investigation** — autonomous agent teams (metrics, logs, topology, correlation, synthesis) fan out in parallel per root-cause candidate
- **Bring your own model** — any OpenAI-compatible LLM via Ollama, vLLM, Together.ai, or Claude
- **Open source** — Apache 2.0

## Stack

| Service | Language | Framework |
|---------|----------|-----------|
| `services/api` | Rust | Axum + sqlx + PostgreSQL |
| `services/agent` | Rust | rig + async-nats |
| `services/collector` | Rust | Aya (eBPF) — _stub_ |
| `services/ui` | TypeScript | React + Vite |
| Messaging | — | NATS |

## Quick start (local demo)

```bash
cd ops
docker compose up --build
```

Open http://localhost:3000 — the demo incident (checkout degradation) is pre-seeded.

To run agent investigation (requires Ollama):

```bash
docker compose --profile llm up --build
# Pull the model once:
docker exec -it ops-ollama-1 ollama pull llama3.1:8b
```

Click **Investigate** on any incident to fan out agent teams and stream findings.

## Architecture

```
eBPF flows (Aya)
      │
      ▼
  NATS bus ──► entropie-agent (rig)
      │              │ MetricsAgent
      │              │ LogsAgent
      │              │ TopologyAgent
      │              │ CorrelationAgent
      │              └ SynthesisAgent
      │
      ▼
  entropie-api (Axum)
      │  /api/incidents/{id}/roots
      │  /api/incidents/{id}/graph
      │  /api/incidents/{id}/investigate  ← SSE stream
      ▼
  React UI
```

## Causal chain algorithm

1. **Detect** anomalies via Prometheus alerts (1-hour baseline lookback)
2. **Discover** topology from eBPF network flows (no hardcoding)
3. **Score edges**: flow exists + temporal ordering (30s window) + metric correlation
4. **Rank** root candidates by outbound causal weight + node boost
5. **Investigate** top-N candidates (score-gap based fan-out) with agent teams

## Validation

```bash
# Run API unit tests
cd services/api && cargo test

# Full integration: docker compose up, then hit the API
curl http://localhost:8080/api/incidents
curl http://localhost:8080/api/incidents/<id>/roots
curl http://localhost:8080/api/incidents/<id>/graph
```

## License

Apache 2.0
