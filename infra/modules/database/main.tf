# ---------------------------------------------------------------------------
# Database module — resources
#
# Managed PostgreSQL instance + the application database + the app DB user,
# bound to the private subnet. Modeled as null_resource so the plan shows the
# managed DB without provisioning (and billing for) a real Cloud SQL instance.
# ---------------------------------------------------------------------------

# --- The managed database instance (private IP only) -----------------------
resource "null_resource" "db_instance" {
  triggers = {
    name              = var.db_instance_name
    project           = var.project
    region            = var.region
    database_version  = var.db_version
    tier              = var.db_tier
    ipv4_enabled      = "false"             # no public IP
    private_network   = var.private_subnet_id # from module.network
    backups_enabled   = "true"
  }
}

# --- The application database on that instance -----------------------------
resource "null_resource" "app_database" {
  triggers = {
    name     = var.db_name
    instance = null_resource.db_instance.id
  }
}

# --- The application database user -----------------------------------------
resource "null_resource" "app_db_user" {
  triggers = {
    name     = var.db_user
    instance = null_resource.db_instance.id
    # Password is NOT stored here — it comes from Secret Manager at runtime,
    # matching the .env -> Secret Manager mapping. Nothing secret in state.
    password_source = "secret-manager"
  }
}
