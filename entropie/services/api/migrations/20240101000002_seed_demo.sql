-- Demo dataset: node CPU pressure -> payments latency -> checkout errors
INSERT INTO incidents (id, title, start_ts, end_ts)
VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'Checkout degradation (demo)',
    '2026-03-09T00:00:00Z',
    '2026-03-09T00:10:00Z'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO anomalies (id, incident_id, ts, entity_type, entity_id, metric, severity, confidence, domain, details)
VALUES
    ('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', '2026-03-09T00:01:00Z', 'node',    'node-1',                  'node_cpu_pressure',   0.7,  0.8,  'infra',    '{"note":"cpu pressure up"}'),
    ('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', '2026-03-09T00:02:00Z', 'service', 'payments/payments-api',   'svc_tcp_retransmits', 0.8,  0.7,  'payments', '{"note":"retransmits spike"}'),
    ('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', '2026-03-09T00:03:00Z', 'service', 'payments/payments-api',   'svc_latency_p95',     0.9,  0.75, 'payments', '{"note":"p95 latency high"}'),
    ('b0000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000001', '2026-03-09T00:04:00Z', 'service', 'checkout/checkout-api',   'svc_http_5xx_rate',   0.95, 0.8,  'checkout', '{"note":"5xx rate increased"}'),
    ('b0000000-0000-0000-0000-000000000005', 'a0000000-0000-0000-0000-000000000001', '2026-03-09T00:05:00Z', 'service', 'checkout/checkout-api',   'svc_slo_burn',        0.85, 0.7,  'checkout', '{"note":"SLO burn"}')
ON CONFLICT (id) DO NOTHING;
