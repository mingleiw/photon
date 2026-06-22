CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS incidents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    start_ts TIMESTAMPTZ NOT NULL,
    end_ts TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS anomalies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    ts TIMESTAMPTZ NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    metric TEXT NOT NULL,
    severity DOUBLE PRECISION NOT NULL,
    confidence DOUBLE PRECISION NOT NULL,
    domain TEXT,
    details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS findings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    summary TEXT NOT NULL,
    revised_confidence DOUBLE PRECISION NOT NULL,
    evidence JSONB NOT NULL DEFAULT '[]',
    proposed_fix JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_anomalies_incident_ts ON anomalies(incident_id, ts);
CREATE INDEX IF NOT EXISTS idx_anomalies_entity ON anomalies(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_findings_incident ON findings(incident_id);
