# CloudNotes — Local Deployment → Google Compute Engine Mapping

This maps each piece of the CloudNotes deployment (built in a GitHub Codespace)
to its Google Compute Engine (GCE) equivalent, with one sentence per row
explaining why the two play the same role.

| What I built locally | Compute Engine equivalent | Why they play the same role |
|----------------------|---------------------------|------------------------------|
| **Linux server** — GitHub Codespace (Ubuntu dev container) | **Compute Engine VM** (e2-medium, Ubuntu) | Both are the Linux host that runs the application; the Codespace is a managed container, the GCE VM is a managed virtual machine, but each is the OS environment CloudNotes runs on. |
| **Terminal / shell** — the Codespaces VS Code terminal | **`gcloud compute ssh`** | Both give me an interactive shell on the server to install packages, edit config, and run commands — one through the browser IDE, the other over SSH. |
| **`localhost:5000` / Codespaces forwarded port** | **VM static external IP** (e.g. `http://<VM_IP>:5000`) | Both are the address a browser uses to reach the running app; the forwarded Codespaces URL and the VM's external IP each expose port 5000 to the outside. |
| **Open port** — Codespaces port forwarding of `:5000` | **GCP VPC firewall rule** `allow tcp:5000` | Both decide which traffic is allowed to reach the app; Codespaces forwarding permits `:5000` the same way a VPC ingress rule opens `tcp:5000` to the VM. |
| **Managed service** — `supervisord` (auto-start + restart-on-crash) | **`systemd` on the VM** | Both keep the app running as an always-on background service that starts automatically and restarts on failure; supervisord is used because the container has no systemd, but the role is identical. |
| **PostgreSQL installed in the container** | **Cloud SQL for PostgreSQL** (managed, LU 2.7) | Both are the PostgreSQL database CloudNotes connects to over a connection string; the local server becomes a managed Cloud SQL instance with backups and failover, but the app code and schema are unchanged. |
| **`.env` / environment variables** | **Instance metadata / Secret Manager** | Both supply configuration and secrets (DB connection string, secret key) to the app at runtime without hard-coding them; `.env` is read locally, while GCE reads them from instance metadata or Secret Manager. |

## Summary

The deployment is intentionally structured so the move to Compute Engine is a
swap of *where* each role runs, not a rewrite: the Codespace becomes a GCE VM,
supervisord becomes systemd, the forwarded port becomes a VPC firewall rule,
local PostgreSQL becomes Cloud SQL, and `.env` becomes Secret Manager. Because
the app reads its database and secrets from environment variables and talks to
PostgreSQL over a standard connection string, the same `app.py` and
`requirements.txt` run in both places with only configuration changing.
