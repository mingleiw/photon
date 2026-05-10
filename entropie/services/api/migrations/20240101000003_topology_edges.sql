CREATE TABLE IF NOT EXISTS topology_edges (
    id           BIGSERIAL PRIMARY KEY,
    src_service  TEXT NOT NULL,
    dst_service  TEXT NOT NULL,
    weight       DOUBLE PRECISION NOT NULL,
    conn_count   BIGINT NOT NULL DEFAULT 0,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (src_service, dst_service)
);

CREATE INDEX IF NOT EXISTS idx_topo_edges_updated ON topology_edges (updated_at DESC);
