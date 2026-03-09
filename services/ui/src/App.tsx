import React, { useEffect, useMemo, useState } from 'react'

type Incident = { id: string; title: string; startTs: string }

type Root = { entityType: string; entityId: string; score: number; rationale: string }

type HeatCell = { domain: string; weight: number }

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

export default function App() {
  const [incidents, setIncidents] = useState<Incident[]>([])
  const [selected, setSelected] = useState<string>('')
  const [roots, setRoots] = useState<Root[]>([])
  const [heat, setHeat] = useState<HeatCell[]>([])
  const [anoms, setAnoms] = useState<Anomaly[]>([])
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
      getJSON<Root[]>(`/api/incidents/${selected}/roots`),
      getJSON<HeatCell[]>(`/api/incidents/${selected}/heatmap`),
      getJSON<Anomaly[]>(`/api/incidents/${selected}/anomalies`)
    ])
      .then(([r, h, a]) => {
        setRoots(r)
        setHeat(h)
        setAnoms(a)
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
