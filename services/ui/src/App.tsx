import React, { useEffect, useMemo, useState } from 'react'

type Incident = { id: string; title: string; startTs: string }

type Root = { entityType: string; entityId: string; score: number; rationale: string }

type HeatCell = { domain: string; weight: number }

type Graph = { nodes: GraphNode[]; edges: GraphEdge[] }
type GraphNode = { id: string; entityType: string; entityId: string; weight: number; domain?: string }
type GraphEdge = { from: string; to: string; weight: number; rationale: string }

type Anomaly = { id: string; ts: string; entityType: string; entityId: string; metric: string; severity: number; confidence: number; domain?: string }

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
      getJSON<Root[]>(`/api/incidents//roots`),
      getJSON<HeatCell[]>(`/api/incidents//heatmap`),
      getJSON<Anomaly[]>(`/api/incidents//anomalies`),
      getJSON<Graph>(`/api/incidents//graph`)
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

  return (
    <div style={{ fontFamily: 'ui-sans-serif, system-ui', padding: 20, maxWidth: 1100, margin: '0 auto' }}>
      <h1 style={{ marginBottom: 6 }}>Photon — Fault Chain Demo</h1>
      <div style={{ color: '#555', marginBottom: 18 }}>
        eBPF-first MVP (demo data). Root-cause ranking + impact heat map.
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
            <h3 style={{ marginTop: 0 }}>Root cause candidates</h3>
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
            <h3 style={{ marginTop: 0 }}>Dependency / fault-chain graph (demo)</h3>
            <GraphView graph={graph} />
            <div style={{ color: '#666', fontSize: 12, marginTop: 6 }}>
              Edges are inferred for demo. In v1, service dependencies come from Cilium/Hubble flows.
            </div>
          </div>

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
