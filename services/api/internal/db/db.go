package db

import (
	"context"
	"embed"
	"fmt"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
)

//go:embed migrations/*.sql
var migrationFS embed.FS

type DB struct {
	Pool *pgxpool.Pool
}

func Open(ctx context.Context, url string) (*DB, error) {
	pool, err := pgxpool.New(ctx, url)
	if err != nil {
		return nil, err
	}
	return &DB{Pool: pool}, nil
}

func (d *DB) Close() { d.Pool.Close() }

// Migrate applies SQL files in lexical order.
func (d *DB) Migrate(ctx context.Context) error {
	entries, err := migrationFS.ReadDir("migrations")
	if err != nil {
		return err
	}
	var files []string
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if strings.HasSuffix(name, ".sql") {
			files = append(files, name)
		}
	}
	sort.Strings(files)
	for _, f := range files {
		b, err := migrationFS.ReadFile("migrations/" + f)
		if err != nil {
			return err
		}
		if _, err := d.Pool.Exec(ctx, string(b)); err != nil {
			return fmt.Errorf("migration %s failed: %w", f, err)
		}
	}
	return nil
}
