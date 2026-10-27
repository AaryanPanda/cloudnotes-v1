# CloudNotes — Deployment (LU 2.2)

This document records how CloudNotes v1.0 was deployed from a local Flask +
SQLite prototype into an always-on, browser-reachable service backed by
PostgreSQL, running in a **GitHub Codespace** (a Linux container).

---

## 1. Environment

| Item | Value |
|------|-------|
| Server environment | GitHub Codespaces (Ubuntu-based dev container, Python 3.11) |
| Web server | gunicorn (WSGI), binding `0.0.0.0:5000` |
| Managed service | `supervisord` (auto-start + restart-on-crash) |
| Database | PostgreSQL 16 (local to the container) |
| Config | environment variables, loaded from `.env` (see `.env.example`) |

**Why Codespaces + supervisord instead of a VM + systemd?**
A Codespace is a container and does not run `systemd`, and there is no physical
host to reboot. `supervisord` plays the same role systemd plays on a VM: it
starts the app and restarts it automatically if it crashes. The devcontainer's
`postStartCommand` launches supervisord every time the Codespace starts (after
being stopped/resumed), which is the container equivalent of "start on boot".
The `cloud-mapping.md` file maps each of these to its Compute Engine + systemd
equivalent.

---

## 2. Setup commands

All of this is automated by `deploy/setup.sh` (run once, via the devcontainer
`postCreateCommand`) and `deploy/start.sh` (run on every Codespace start). The
exact steps they perform:

```bash
# 2.1 Install Python dependencies (Flask, gunicorn, psycopg, python-dotenv)
pip install -r requirements.txt
pip install supervisor

# 2.2 Start PostgreSQL and create the database + user for CloudNotes
sudo service postgresql start
sudo -u postgres psql -c "CREATE ROLE cloudnotes LOGIN PASSWORD 'cloudnotes_pw';"
sudo -u postgres psql -c "CREATE DATABASE cloudnotes_db OWNER cloudnotes;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE cloudnotes_db TO cloudnotes;"

# 2.3 Create the real .env from the template and fill in values
cp .env.example .env
#   -> set SECRET_KEY and confirm DATABASE_URL points at the database above

# 2.4 Start CloudNotes as a managed service (gunicorn under supervisord)
bash deploy/start.sh
```

The schema (`notes` table) is created automatically at app startup by
`init_db()` in `utils/helpers.py`, so no separate migration command is needed.

### Service management (the "managed service")

```bash
# status of the managed service
supervisorctl -c deploy/supervisord.conf status

# restart the app
supervisorctl -c deploy/supervisord.conf restart cloudnotes
```

- **Auto-restart on crash:** `autorestart=true` in `deploy/supervisord.conf`.
  Kill the gunicorn process and supervisord respawns it (different PID, still
  RUNNING).
- **Start on (container) boot:** `postStartCommand` in
  `.devcontainer/devcontainer.json` runs `deploy/start.sh` each time the
  Codespace starts.

---

## 3. Making it reachable

- The app binds to **`0.0.0.0:5000`** (not `127.0.0.1`), so it is reachable on
  all interfaces inside the container — see `gunicorn --bind 0.0.0.0:5000` in
  `deploy/supervisord.conf`.
- Codespaces **forwards port 5000** automatically (`forwardPorts: [5000]` in the
  devcontainer). Open the forwarded URL from the **Ports** tab to load
  CloudNotes in a browser.
- On a real VM the equivalent step is opening the OS firewall:
  `sudo ufw allow 5000/tcp`. In Codespaces the forwarded port plays that role;
  there is no separate host firewall to open.

Confirm it loads:

```bash
curl http://localhost:5000/health      # -> {"status":"healthy"}
curl http://localhost:5000/            # -> CloudNotes home page (HTTP 200)
```

### Request path (in my own words)

```
your browser
   -> Codespaces forwarded port (HTTPS tunnel)         [= host/VM network]
   -> container network / forwarded :5000              [= OS firewall / open port]
   -> gunicorn listening on 0.0.0.0:5000               [= Linux server]
   -> Flask app (app:app), routes the request          [= Flask on 0.0.0.0:5000]
   -> PostgreSQL (localhost:5432) for note data
   -> response travels back out the same path
```

On a VM this would be: *browser → VM network / port-forward → `ufw` open port →
Linux server → gunicorn → Flask → PostgreSQL*. The Codespaces forwarded port
stands in for the VM network + firewall hop.

---

## 4. Persistence (the point of the task)

Data lives in PostgreSQL on the container's persistent volume, not in the app
process, so it survives app restarts and Codespace stop/resume:

```bash
# add a note
curl -X POST http://localhost:5000/api/notes -F "title=Persist" -F "body=survives restart"

# restart the app (managed service)
supervisorctl -c deploy/supervisord.conf restart cloudnotes

# the note is still there
curl http://localhost:5000/api/notes
#   -> the "Persist" note is returned
```

Verified directly in the database as well:

```bash
sudo -u postgres psql -d cloudnotes_db -c "SELECT id, title FROM notes;"
```

---

## 5. Files in this deployment

| File | Purpose |
|------|---------|
| `app.py` | App factory; reads all config from env vars; exposes `app` for gunicorn |
| `utils/helpers.py` | DB layer supporting SQLite (dev) and PostgreSQL (prod) via `DATABASE_URL` |
| `api/routes.py` | Notes REST API, engine-agnostic queries |
| `requirements.txt` | Flask, gunicorn, psycopg, python-dotenv |
| `.env.example` | Placeholder config (copy to `.env`; real `.env` is git-ignored) |
| `deploy/supervisord.conf` | Managed-service definition (auto-start + restart-on-crash) |
| `deploy/start.sh` | Loads `.env` and starts/restarts the service |
| `deploy/setup.sh` | One-time install + database/user creation |
| `.devcontainer/devcontainer.json` | Codespaces setup, port forwarding, start-on-boot |
| `cloud-mapping.md` | Maps this deployment to Google Compute Engine |
