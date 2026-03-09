-- incidents represent a grouped set of anomalies in a time window
create table if not exists incidents (
  id text primary key,
  title text not null,
  start_ts timestamptz not null,
  end_ts timestamptz,
  created_at timestamptz not null default now()
);

-- anomalies are fault nodes detected from telemetry
create table if not exists anomalies (
  id text primary key,
  incident_id text not null references incidents(id) on delete cascade,
  ts timestamptz not null,
  entity_type text not null, -- service|node
  entity_id text not null,   -- svc namespace/name or node name
  metric text not null,
  severity double precision not null,
  confidence double precision not null,
  domain text,
  details jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_anomalies_incident_ts on anomalies(incident_id, ts);
create index if not exists idx_anomalies_entity on anomalies(entity_type, entity_id);
