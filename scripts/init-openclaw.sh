#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f ".env" ]]; then
  echo "Missing .env. Copy .env.example to .env first." >&2
  exit 1
fi

export $(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' .env | xargs)

if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
  echo "OPENCLAW_GATEWAY_TOKEN is required." >&2
  exit 1
fi

echo "==> Running onboarding"
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js onboard --mode local --no-install-daemon

echo "==> Writing Docker-friendly gateway config"
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.mode local
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.bind lan
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.controlUi.allowedOrigins '["http://127.0.0.1:18789"]' --strict-json
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config set gateway.auth.token "$OPENCLAW_GATEWAY_TOKEN"

echo "==> Recreating gateway container"
docker compose stop openclaw-gateway || true
docker compose rm -f openclaw-gateway || true
docker compose up -d --force-recreate openclaw-gateway

echo "==> Recent gateway logs"
docker compose logs --tail=50 openclaw-gateway
