#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

DOCKER_BUILDKIT=1 docker compose -f compose.yml up -d --build

# Wait for api
for i in $(seq 1 60); do
  if curl -sf http://127.0.0.1:8080/healthz >/dev/null; then
    break
  fi
  sleep 1
done

# Wait for UI
for i in $(seq 1 60); do
  if curl -sf http://127.0.0.1:8081/ >/dev/null; then
    echo "api + ui are healthy"
    exit 0
  fi
  sleep 1
done

echo "ui did not become healthy in time" >&2
exit 1
