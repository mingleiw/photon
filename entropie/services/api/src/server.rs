use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{
        sse::{Event, Sse},
        IntoResponse, Json,
    },
    routing::get,
    Router,
};
use futures::{stream::Stream, StreamExt};
use serde_json::json;
use sqlx::PgPool;
use std::{convert::Infallible, sync::Arc, time::Duration};
use uuid::Uuid;

use crate::{
    chain::{build_graph, heatmap, score_roots},
    model::{Anomaly, Incident, TopologyEdge},
};

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub nats: Option<Arc<async_nats::Client>>,
}

pub fn router(state: AppState) -> Router {
    Router::new()
        .route("/healthz", get(healthz))
        .route("/api/incidents", get(list_incidents))
        .route("/api/incidents/:id/anomalies", get(get_anomalies))
        .route("/api/incidents/:id/roots", get(get_roots))
        .route("/api/incidents/:id/heatmap", get(get_heatmap))
        .route("/api/incidents/:id/graph", get(get_graph))
        .route("/api/incidents/:id/investigate", get(investigate_sse))
        .with_state(state)
}

async fn healthz() -> impl IntoResponse {
    Json(json!({"status": "ok"}))
}

async fn list_incidents(State(s): State<AppState>) -> impl IntoResponse {
    let rows = sqlx::query_as::<_, Incident>("SELECT id, title, start_ts, end_ts FROM incidents ORDER BY start_ts DESC")
        .fetch_all(&s.pool)
        .await;

    match rows {
        Ok(incidents) => Json(json!(incidents)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({"error": e.to_string()}))).into_response(),
    }
}

async fn get_anomalies(State(s): State<AppState>, Path(id): Path<Uuid>) -> impl IntoResponse {
    let rows = sqlx::query_as::<_, Anomaly>(
        "SELECT id, incident_id, ts, entity_type, entity_id, metric, severity, confidence, domain, details
         FROM anomalies WHERE incident_id = $1 ORDER BY ts ASC",
    )
    .bind(id)
    .fetch_all(&s.pool)
    .await;

    match rows {
        Ok(anomalies) => Json(json!(anomalies)).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({"error": e.to_string()}))).into_response(),
    }
}

async fn get_roots(State(s): State<AppState>, Path(id): Path<Uuid>) -> impl IntoResponse {
    match fetch_anomalies(&s.pool, id).await {
        Ok(anomalies) => Json(json!(score_roots(&anomalies))).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({"error": e.to_string()}))).into_response(),
    }
}

async fn get_heatmap(State(s): State<AppState>, Path(id): Path<Uuid>) -> impl IntoResponse {
    match fetch_anomalies(&s.pool, id).await {
        Ok(anomalies) => Json(json!(heatmap(&anomalies))).into_response(),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({"error": e.to_string()}))).into_response(),
    }
}

async fn get_graph(State(s): State<AppState>, Path(id): Path<Uuid>) -> impl IntoResponse {
    let anomalies = match fetch_anomalies(&s.pool, id).await {
        Ok(a) => a,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({"error": e.to_string()}))).into_response(),
    };
    let live_edges = sqlx::query_as::<_, TopologyEdge>(
        "SELECT src_service, dst_service, weight, conn_count FROM topology_edges ORDER BY updated_at DESC",
    )
    .fetch_all(&s.pool)
    .await
    .unwrap_or_default();
    Json(json!(build_graph(&anomalies, &live_edges))).into_response()
}

// SSE endpoint — triggers agent investigation and streams findings back to the UI
async fn investigate_sse(
    State(s): State<AppState>,
    Path(id): Path<Uuid>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let nats = s.nats.clone();
    let findings_subject = format!("findings.{}.*", id);

    // Subscribe BEFORE publishing: agent may complete before the stream starts consuming,
    // and messages published before subscription are lost in core NATS (no persistence).
    let pre_sub: Option<async_nats::Subscriber> = if let Some(ref n) = nats {
        match n.subscribe(findings_subject).await {
            Ok(sub) => {
                let subject = format!("investigate.{}", id);
                let _ = n.publish(subject, id.to_string().into()).await;
                Some(sub)
            }
            Err(_) => None,
        }
    } else {
        None
    };

    let stream = async_stream::stream! {
        if nats.is_none() {
            yield Ok(Event::default().data(r#"{"error":"NATS not configured"}"#));
            return;
        }
        if let Some(mut sub) = pre_sub {
            let timeout = tokio::time::sleep(Duration::from_secs(120));
            tokio::pin!(timeout);

            loop {
                tokio::select! {
                    msg = sub.next() => {
                        match msg {
                            Some(m) => {
                                let data = String::from_utf8_lossy(&m.payload).to_string();
                                yield Ok(Event::default().data(&data));
                                if let Ok(f) = serde_json::from_str::<serde_json::Value>(&data) {
                                    if f.get("done").and_then(|v| v.as_bool()).unwrap_or(false) {
                                        break;
                                    }
                                }
                            }
                            None => break,
                        }
                    }
                    _ = &mut timeout => break,
                }
            }
        }
    };

    Sse::new(stream).keep_alive(
        axum::response::sse::KeepAlive::new().interval(Duration::from_secs(15)),
    )
}

async fn fetch_anomalies(pool: &PgPool, incident_id: Uuid) -> anyhow::Result<Vec<Anomaly>> {
    let rows = sqlx::query_as::<_, Anomaly>(
        "SELECT id, incident_id, ts, entity_type, entity_id, metric, severity, confidence, domain, details
         FROM anomalies WHERE incident_id = $1 ORDER BY ts ASC",
    )
    .bind(incident_id)
    .fetch_all(pool)
    .await?;
    Ok(rows)
}
