#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_URL="${OPENCLAW_REPO_URL:-https://github.com/openclaw/openclaw.git}"
TARGET_DIR="${OPENCLAW_SRC_DIR:-$ROOT_DIR/openclaw}"
BRANCH="${OPENCLAW_BRANCH:-main}"

if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "Updating existing OpenClaw repository in $TARGET_DIR"
  git -C "$TARGET_DIR" fetch origin
  git -C "$TARGET_DIR" checkout "$BRANCH"
  git -C "$TARGET_DIR" pull --ff-only origin "$BRANCH"
else
  echo "Cloning OpenClaw repository into $TARGET_DIR"
  git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$TARGET_DIR"
fi

echo "OpenClaw source ready: $TARGET_DIR"
