#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

# Bring up stack
DOCKER_BUILDKIT=1 docker compose -f compose.yml up -d --build

# Wait for api
for i in $(seq 1 60); do
  if curl -sf http://127.0.0.1:8080/healthz >/dev/null; then
    echo "api is healthy"
    exit 0
  fi
  sleep 1
done

echo "api did not become healthy in time" >&2
exit 1
