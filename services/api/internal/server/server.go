package server

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5"

	"photon-api/internal/chain"
	"photon-api/internal/db"
	"photon-api/internal/model"
)

type Server struct {
	DB *db.DB
}

func New(d *db.DB) *Server { return &Server{DB: d} }

func (s *Server) Router() http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(10 * time.Second))

	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"status": "ok"})
	})

	r.Route("/api", func(r chi.Router) {
		r.Get("/incidents", s.handleIncidents)
		r.Get("/incidents/{id}/anomalies", s.handleAnomalies)
		r.Get("/incidents/{id}/roots", s.handleRoots)
		r.Get("/incidents/{id}/heatmap", s.handleHeatmap)
		r.Get("/incidents/{id}/graph", s.handleGraph)
	})

	return r
}

func (s *Server) handleIncidents(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	rows, err := s.DB.Pool.Query(ctx, `select id,title,start_ts,end_ts from incidents order by start_ts desc`)
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err)
		return
	}
	defer rows.Close()
	var out []model.Incident
	for rows.Next() {
		var it model.Incident
		if err := rows.Scan(&it.ID, &it.Title, &it.StartTs, &it.EndTs); err != nil {
			writeErr(w, 500, err)
			return
		}
		out = append(out, it)
	}
	writeJSON(w, 200, out)
}

func (s *Server) incidentAnomalies(ctx context.Context, id string) ([]model.Anomaly, error) {
	rows, err := s.DB.Pool.Query(ctx, `select id,incident_id,ts,entity_type,entity_id,metric,severity,confidence,domain from anomalies where incident_id=$1 order by ts asc`, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []model.Anomaly
	for rows.Next() {
		var a model.Anomaly
		if err := rows.Scan(&a.ID, &a.IncidentID, &a.Ts, &a.EntityType, &a.EntityID, &a.Metric, &a.Severity, &a.Confidence, &a.Domain); err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, nil
}

func (s *Server) handleAnomalies(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	anoms, err := s.incidentAnomalies(r.Context(), id)
	if err != nil {
		if err == pgx.ErrNoRows {
			writeJSON(w, 404, []model.Anomaly{})
			return
		}
		writeErr(w, 500, err)
		return
	}
	writeJSON(w, 200, anoms)
}

func (s *Server) handleRoots(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	anoms, err := s.incidentAnomalies(r.Context(), id)
	if err != nil {
		writeErr(w, 500, err)
		return
	}
	writeJSON(w, 200, chain.ScoreRoots(anoms))
}

func (s *Server) handleHeatmap(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	anoms, err := s.incidentAnomalies(r.Context(), id)
	if err != nil {
		writeErr(w, 500, err)
		return
	}
	writeJSON(w, 200, chain.Heatmap(anoms))
}

func (s *Server) handleGraph(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	anoms, err := s.incidentAnomalies(r.Context(), id)
	if err != nil {
		writeErr(w, 500, err)
		return
	}
	writeJSON(w, 200, chain.BuildGraph(anoms))
}

func writeErr(w http.ResponseWriter, code int, err error) {
	writeJSON(w, code, map[string]any{"error": err.Error()})
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}
