package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus/promhttp"

	"photon-api/internal/db"
	"photon-api/internal/server"
)

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	port := getenv("PORT", "8080")
	dbURL := getenv("DATABASE_URL", "")
	if dbURL == "" {
		log.Fatal("DATABASE_URL is required")
	}

	d, err := db.Open(ctx, dbURL)
	if err != nil {
		log.Fatalf("db open: %v", err)
	}
	defer d.Close()
	if err := d.Migrate(ctx); err != nil {
		log.Fatalf("db migrate: %v", err)
	}

	srv := server.New(d)
	r := http.NewServeMux()
	r.Handle("/metrics", promhttp.Handler())
	r.Handle("/", srv.Router())

	addr := fmt.Sprintf(":%s", port)
	log.Printf("listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, r))
}

func getenv(k, def string) string {
	v := os.Getenv(k)
	if v == "" {
		return def
	}
	return v
}
