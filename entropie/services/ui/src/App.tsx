import React, { useEffect, useMemo, useRef, useState } from 'react'

type Incident = { id: string; title: string; startTs: string }

type Root = { entityType: string; entityId: string; score: number; rationale: string }

type HeatCell = { domain: string; weight: number }

type Graph = { nodes: GraphNode[]; edges: GraphEdge[] }
type GraphNode = { id: string; entityType: string; entityId: string; weight: number; domain?: string }
type GraphEdge = { from: string; to: string; weight: number; rationale: string }

type Anomaly = { id: string; ts: string; entityType: string; entityId: string; metric: string; severity: number; confidence: number; domain?: string }

type ProposedFix = { description: string; command?: string; requires_approval: boolean }
type Finding = { entity_type: string; entity_id: string; summary: string; revised_confidence: number; evidence: { source: string; summary: string }[]; proposed_fix?: ProposedFix; done?: boolean }

async function getJSON<T>(path: string): Promise<T> {
  const r = await fetch(path)
  if (!r.ok) throw new Error(`${path}: ${r.status}`)
  return r.json() as Promise<T>
}

function barWidth(w: number, max: number) {
  if (max <= 0) return '0%'
  return `${Math.round((w / max) * 100)}%`
}


function GraphView({ graph }: { graph: Graph }) {
  const nodes = graph.nodes
  const edges = graph.edges
  if (!nodes.length) return <div style={{ color: '#777' }}>No graph data.</div>

  const width = 760
  const height = 220
  const pad = 18

  // simple deterministic layout: node->service1->service2 in a row by type
  const sorted = [...nodes].sort((a, b) => a.id.localeCompare(b.id))
  const groups: Record<string, GraphNode[]> = { node: [], service: [] }
  for (const n of sorted) {
    ;(groups[n.entityType] ?? (groups[n.entityType] = [])).push(n)
  }

  const positioned: Record<string, { x: number; y: number; n: GraphNode }> = {}
  const lanes = [
    { t: 'node', y: height * 0.35 },
    { t: 'service', y: height * 0.70 }
  ]
  for (const lane of lanes) {
    const arr = groups[lane.t] ?? []
    const step = arr.length > 1 ? (width - pad * 2) / (arr.length - 1) : 0
    arr.forEach((n, i) => {
      const x = pad + (arr.length === 1 ? (width - pad * 2) / 2 : i * step)
      positioned[n.id] = { x, y: lane.y, n }
    })
  }

  const maxW = Math.max(0, ...nodes.map((n) => n.weight))
  const nodeColor = (n: GraphNode) => {
    if (n.entityType === 'node') return '#1f77b4'
    if ((n.domain ?? '').toLowerCase().includes('checkout')) return '#e94560'
    if ((n.domain ?? '').toLowerCase().includes('payments')) return '#ff8c00'
    return '#444'
  }

  return (
    <svg width={width} height={height} style={{ width: '100%', height: 'auto', background: '#fafafa', borderRadius: 10, border: '1px solid #eee' }}>
      <defs>
        <marker id="arrow" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto" markerUnits="strokeWidth">
          <path d="M0,0 L0,6 L9,3 z" fill="#666" />
        </marker>
      </defs>

      {edges.map((e) => {
        const a = positioned[e.from]
        const b = positioned[e.to]
        if (!a || !b) return null
        const strokeW = 1 + (e.weight / (1 || 1)) * 2
        return (
          <g key={`${e.from}->${e.to}`}>
            <line x1={a.x} y1={a.y} x2={b.x} y2={b.y} stroke="#666" strokeWidth={strokeW} markerEnd="url(#arrow)" />
            <title>{e.rationale}</title>
          </g>
        )
      })}

      {nodes.map((n) => {
        const p = positioned[n.id]
        if (!p) return null
        const r = 10 + (maxW ? (n.weight / maxW) * 10 : 0)
        const label = `${n.entityType}: ${n.entityId}`
        return (
          <g key={n.id}>
            <circle cx={p.x} cy={p.y} r={r} fill={nodeColor(n)} opacity={0.92} />
            <text x={p.x} y={p.y - r - 6} textAnchor="middle" fontSize="11" fill="#222">
              {label}
            </text>
            <title>{label}
weight: {n.weight.toFixed(3)}</title>
          </g>
        )
      })}
    </svg>
  )
}

export default function App() {
  const [incidents, setIncidents] = useState<Incident[]>([])
  const [selected, setSelected] = useState<string>('')
  const [roots, setRoots] = useState<Root[]>([])
  const [heat, setHeat] = useState<HeatCell[]>([])
  const [anoms, setAnoms] = useState<Anomaly[]>([])
  const [graph, setGraph] = useState<Graph>({ nodes: [], edges: [] })
  const [err, setErr] = useState<string>('')
  const [findings, setFindings] = useState<Finding[]>([])
  const [investigating, setInvestigating] = useState(false)
  const sseRef = useRef<EventSource | null>(null)

  useEffect(() => {
    getJSON<Incident[]>('/api/incidents')
      .then((xs) => {
        setIncidents(xs)
        if (xs.length) setSelected(xs[0].id)
      })
      .catch((e) => setErr(String(e)))
  }, [])

  useEffect(() => {
    if (!selected) return
    setErr('')
    Promise.all([
      getJSON<Root[]>(`/api/incidents/${selected}/roots`),
      getJSON<HeatCell[]>(`/api/incidents/${selected}/heatmap`),
      getJSON<Anomaly[]>(`/api/incidents/${selected}/anomalies`),
      getJSON<Graph>(`/api/incidents/${selected}/graph`)
    ])
      .then(([r, h, a, g]) => {
        setRoots(r)
        setHeat(h)
        setAnoms(a)
        setGraph(g)
      })
      .catch((e) => setErr(String(e)))
  }, [selected])

  const maxHeat = useMemo(() => Math.max(0, ...heat.map((x) => x.weight)), [heat])

  function startInvestigation() {
    if (!selected || investigating) return
    setFindings([])
    setInvestigating(true)
    if (sseRef.current) sseRef.current.close()
    const es = new EventSource(`/api/incidents/${selected}/investigate`)
    sseRef.current = es
    es.onmessage = (e) => {
      try {
        const f: Finding = JSON.parse(e.data)
        if (f.done) { setInvestigating(false); es.close(); return }
        setFindings((prev) => [...prev.filter((x) => x.entity_id !== f.entity_id), f])
      } catch {}
    }
    es.onerror = () => { setInvestigating(false); es.close() }
  }

  return (
    <div style={{ fontFamily: 'ui-sans-serif, system-ui', padding: 20, maxWidth: 1100, margin: '0 auto' }}>
      <h1 style={{ marginBottom: 6 }}>Entropie — Root Cause Investigation</h1>
      <div style={{ color: '#555', marginBottom: 18 }}>
        eBPF-first incident analysis. Multi-agent root-cause investigation.
      </div>

      {err ? (
        <div style={{ background: '#fee', border: '1px solid #f99', padding: 10, borderRadius: 8, marginBottom: 12 }}>
          {err}
        </div>
      ) : null}

      <div style={{ display: 'grid', gridTemplateColumns: '280px 1fr', gap: 16 }}>
        <div style={{ border: '1px solid #eee', borderRadius: 10, padding: 12 }}>
          <h3 style={{ marginTop: 0 }}>Incidents</h3>
          {incidents.map((i) => (
            <button
              key={i.id}
              onClick={() => setSelected(i.id)}
              style={{
                width: '100%', textAlign: 'left', padding: 10, marginBottom: 8,
                borderRadius: 8, border: '1px solid #ddd',
                background: i.id === selected ? '#111' : '#fff',
                color: i.id === selected ? '#fff' : '#111',
                cursor: 'pointer'
              }}
            >
              <div style={{ fontWeight: 700 }}>{i.title}</div>
              <div style={{ fontSize: 12, opacity: 0.75 }}>{new Date(i.startTs).toLocaleString()}</div>
            </button>
          ))}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
          <div style={{ border: '1px solid #eee', borderRadius: 10, padding: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <h3 style={{ margin: 0 }}>Root cause candidates</h3>
              <button
                onClick={startInvestigation}
                disabled={!selected || investigating}
                style={{ padding: '6px 14px', borderRadius: 6, border: 'none', background: investigating ? '#aaa' : '#111', color: '#fff', cursor: investigating ? 'default' : 'pointer', fontSize: 13 }}
              >
                {investigating ? 'Investigating…' : 'Investigate'}
              </button>
            </div>
            {roots.slice(0, 5).map((r) => (
              <div key={`${r.entityType}:${r.entityId}`} style={{ marginBottom: 12 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <div style={{ fontWeight: 700 }}>{r.entityType}: {r.entityId}</div>
                  <div style={{ fontVariantNumeric: 'tabular-nums' }}>{r.score.toFixed(3)}</div>
                </div>
                <div style={{ color: '#666', fontSize: 12 }}>{r.rationale}</div>
              </div>
            ))}
          </div>

          <div style={{ border: '1px solid #eee', borderRadius: 10, padding: 12 }}>
            <h3 style={{ marginTop: 0 }}>Impact heat map</h3>
            {heat.map((c) => (
              <div key={c.domain} style={{ marginBottom: 10 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <div style={{ fontWeight: 700 }}>{c.domain}</div>
                  <div style={{ fontVariantNumeric: 'tabular-nums' }}>{c.weight.toFixed(3)}</div>
                </div>
                <div style={{ background: '#f2f2f2', borderRadius: 999, overflow: 'hidden', height: 10 }}>
                  <div style={{ width: barWidth(c.weight, maxHeat), background: '#e94560', height: 10 }} />
                </div>
              </div>
            ))}
          </div>

          
          <div style={{ gridColumn: '1 / span 2', border: '1px solid #eee', borderRadius: 10, padding: 12 }}>
            <h3 style={{ marginTop: 0 }}>Dependency / fault-chain graph</h3>
            <GraphView graph={graph} />
            <div style={{ color: '#666', fontSize: 12, marginTop: 6 }}>
              Edges inferred from eBPF network flows and temporal correlation.
            </div>
          </div>

          {findings.length > 0 && (
            <div style={{ gridColumn: '1 / span 2', border: '1px solid #e0e0ff', borderRadius: 10, padding: 12, background: '#fafafe' }}>
              <h3 style={{ marginTop: 0 }}>Agent investigation findings</h3>
              {findings.map((f) => (
                <div key={f.entity_id} style={{ marginBottom: 16, padding: 12, border: '1px solid #eee', borderRadius: 8, background: '#fff' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                    <div style={{ fontWeight: 700 }}>{f.entity_type}: {f.entity_id}</div>
                    <div style={{ fontVariantNumeric: 'tabular-nums', color: f.revised_confidence > 0.7 ? '#c00' : '#555' }}>
                      confidence: {(f.revised_confidence * 100).toFixed(0)}%
                    </div>
                  </div>
                  <div style={{ marginBottom: 8 }}>{f.summary}</div>
                  {f.evidence.map((e) => (
                    <div key={e.source} style={{ fontSize: 12, color: '#666', marginBottom: 4 }}>
                      <strong>[{e.source}]</strong> {e.summary}
                    </div>
                  ))}
                  {f.proposed_fix && (
                    <div style={{ marginTop: 8, padding: 8, background: '#fff8e1', borderRadius: 6, fontSize: 13 }}>
                      <strong>Proposed fix:</strong> {f.proposed_fix.description}
                      {f.proposed_fix.command && (
                        <div style={{ fontFamily: 'monospace', marginTop: 4, background: '#f5f5f5', padding: 4, borderRadius: 4 }}>
                          {f.proposed_fix.command}
                        </div>
                      )}
                      <div style={{ color: '#e65c00', fontSize: 11, marginTop: 4 }}>Requires human approval before execution</div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}

<div style={{ gridColumn: '1 / span 2', border: '1px solid #eee', borderRadius: 10, padding: 12 }}>
            <h3 style={{ marginTop: 0 }}>Fault nodes (anomalies)</h3>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ textAlign: 'left', borderBottom: '1px solid #eee' }}>
                  <th style={{ padding: '8px 6px' }}>Time</th>
                  <th style={{ padding: '8px 6px' }}>Entity</th>
                  <th style={{ padding: '8px 6px' }}>Metric</th>
                  <th style={{ padding: '8px 6px' }}>Severity</th>
                  <th style={{ padding: '8px 6px' }}>Conf</th>
                  <th style={{ padding: '8px 6px' }}>Domain</th>
                </tr>
              </thead>
              <tbody>
                {anoms.map((a) => (
                  <tr key={a.id} style={{ borderBottom: '1px solid #f3f3f3' }}>
                    <td style={{ padding: '8px 6px', fontVariantNumeric: 'tabular-nums' }}>{new Date(a.ts).toLocaleTimeString()}</td>
                    <td style={{ padding: '8px 6px' }}>{a.entityType}: {a.entityId}</td>
                    <td style={{ padding: '8px 6px' }}>{a.metric}</td>
                    <td style={{ padding: '8px 6px' }}>{a.severity.toFixed(2)}</td>
                    <td style={{ padding: '8px 6px' }}>{a.confidence.toFixed(2)}</td>
                    <td style={{ padding: '8px 6px' }}>{a.domain ?? ''}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
