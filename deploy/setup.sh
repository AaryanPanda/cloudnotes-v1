#!/usr/bin/env bash
# One-time setup for the CloudNotes deployment in Codespaces / a fresh container.
# Installs Python dependencies, ensures PostgreSQL has a cloudnotes database and
# user, and creates a local .env from .env.example if one does not exist.
set -euo pipefail

CLOUDNOTES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CLOUDNOTES_DIR"

echo "==> Installing Python dependencies"
pip install --no-cache-dir -r requirements.txt
pip install --no-cache-dir supervisor

echo "==> Ensuring PostgreSQL is running"
# The devcontainer postgresql feature installs a local server. Start it if the
# service manager is available; ignore errors if it is already up.
sudo service postgresql start 2>/dev/null || true
sleep 2

echo "==> Creating database and user (idempotent)"
# Create role + database for CloudNotes if they do not already exist.
sudo -u postgres psql <<'SQL' || true
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cloudnotes') THEN
      CREATE ROLE cloudnotes LOGIN PASSWORD 'cloudnotes_pw';
   END IF;
END
$$;
SQL
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = 'cloudnotes_db'" \
  | grep -q 1 || sudo -u postgres psql -c "CREATE DATABASE cloudnotes_db OWNER cloudnotes;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE cloudnotes_db TO cloudnotes;" || true

echo "==> Preparing .env"
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example (using local PostgreSQL defaults)."
else
  echo ".env already exists; leaving it as-is."
fi

echo "==> Setup complete. The service will be started by deploy/start.sh."
