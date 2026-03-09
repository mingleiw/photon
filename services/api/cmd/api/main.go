package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

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

	mux := http.NewServeMux()
	mux.Handle("/metrics", promhttp.Handler())
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, Health{Status: "ok", Time: time.Now().Format(time.RFC3339)})
	})
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("photon fault-chain api: ok"))
	})

	addr := fmt.Sprintf(":%s", port)
	log.Printf("listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, instrument(mux)))
}

func instrument(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rw := &rec{ResponseWriter: w, code: 200}
		next.ServeHTTP(rw, r)
		reqTotal.WithLabelValues(r.URL.Path, r.Method, fmt.Sprintf("%d", rw.code)).Inc()
	})
}

type rec struct {
	http.ResponseWriter
	code int
}

func (r *rec) WriteHeader(statusCode int) {
	r.code = statusCode
	r.ResponseWriter.WriteHeader(statusCode)
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}
