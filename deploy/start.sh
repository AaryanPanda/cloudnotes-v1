#!/usr/bin/env bash
# Start CloudNotes under supervisord (the managed service).
# Loads environment variables from .env, then launches supervisord which in
# turn runs gunicorn and keeps it alive (restart-on-crash).
set -euo pipefail

# Resolve the repo root (this script lives in deploy/).
CLOUDNOTES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CLOUDNOTES_DIR

cd "$CLOUDNOTES_DIR"

# Load .env if present (export each non-comment KEY=VALUE line).
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
  echo "Loaded environment from .env"
else
  echo "WARNING: no .env found — copy .env.example to .env and fill it in."
fi

# If supervisord is already running, just (re)start the app program.
if supervisorctl -c deploy/supervisord.conf status >/dev/null 2>&1; then
  echo "supervisord already running; restarting cloudnotes..."
  supervisorctl -c deploy/supervisord.conf restart cloudnotes
else
  echo "Starting supervisord..."
  supervisord -c deploy/supervisord.conf
fi

sleep 2
supervisorctl -c deploy/supervisord.conf status
echo
echo "CloudNotes should be reachable on http://localhost:5000"
