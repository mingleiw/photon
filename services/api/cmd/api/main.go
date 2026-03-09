package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"photon-api/internal/httpx"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type Health struct {
	Status string `json:"status"`
	Time   string `json:"time"`
}

var (
	reqTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{Name: "faultchain_http_requests_total", Help: "HTTP requests"},
		[]string{"path", "method", "code"},
	)
)

func main() {
	prometheus.MustRegister(reqTotal)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := routes()

	addr := fmt.Sprintf(":%s", port)
	log.Printf("listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, instrument(mux)))
}

func routes() *http.ServeMux {
	mux := http.NewServeMux()
	mux.Handle("/metrics", promhttp.Handler())
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, Health{Status: "ok", Time: time.Now().Format(time.RFC3339)})
	})
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("photon fault-chain api: ok"))
	})
	return mux
}

func instrument(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rw := httpx.NewRecorder(w)
		next.ServeHTTP(rw, r)
		reqTotal.WithLabelValues(r.URL.Path, r.Method, fmt.Sprintf("%d", rw.Code)).Inc()
	})
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}
