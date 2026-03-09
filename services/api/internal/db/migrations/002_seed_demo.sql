-- deterministic demo dataset
insert into incidents (id, title, start_ts, end_ts)
values
  ('demo-001', 'Checkout degradation (demo)', '2026-03-09T00:00:00Z', '2026-03-09T00:10:00Z')
on conflict (id) do nothing;

-- A plausible chain: node pressure -> payments svc latency -> checkout errors
insert into anomalies (id, incident_id, ts, entity_type, entity_id, metric, severity, confidence, domain, details)
values
  ('a-001', 'demo-001', '2026-03-09T00:01:00Z', 'node', 'node-1', 'node_cpu_pressure', 0.7, 0.8, 'infra', '{"note":"cpu pressure up"}'),
  ('a-002', 'demo-001', '2026-03-09T00:02:00Z', 'service', 'payments/payments-api', 'svc_tcp_retransmits', 0.8, 0.7, 'payments', '{"note":"retransmits spike"}'),
  ('a-003', 'demo-001', '2026-03-09T00:03:00Z', 'service', 'payments/payments-api', 'svc_latency_p95', 0.9, 0.75, 'payments', '{"note":"p95 latency high"}'),
  ('a-004', 'demo-001', '2026-03-09T00:04:00Z', 'service', 'checkout/checkout-api', 'svc_http_5xx_rate', 0.95, 0.8, 'checkout', '{"note":"5xx rate increased"}'),
  ('a-005', 'demo-001', '2026-03-09T00:05:00Z', 'service', 'checkout/checkout-api', 'svc_slo_burn', 0.85, 0.7, 'checkout', '{"note":"SLO burn"}')
on conflict (id) do nothing;
