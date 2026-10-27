# ---------------------------------------------------------------------------
# Root outputs — the useful results of the whole system, re-exposed
#
# These pull selected module outputs up to the top level so that after a real
# apply you would see, at a glance, how to reach the app, where assets live,
# and what the database is called.
# ---------------------------------------------------------------------------

# --- Network ---------------------------------------------------------------
output "network_name" {
  description = "The VPC network name."
  value       = module.network.network_name
}

# --- Compute ---------------------------------------------------------------
output "app_url" {
  description = "URL the CloudNotes app is reachable at."
  value       = module.compute.app_url
}

output "app_instance_name" {
  description = "Name of the application VM."
  value       = module.compute.instance_name
}

# --- Database --------------------------------------------------------------
output "database_name" {
  description = "Name of the application database."
  value       = module.database.db_name
}

output "database_connection_hint" {
  description = "Shape of the DB connection string (no secrets)."
  value       = module.database.db_connection_hint
}

# --- Storage ---------------------------------------------------------------
output "assets_bucket_name" {
  description = "Name of the assets bucket."
  value       = module.storage.bucket_name
}

output "assets_bucket_url" {
  description = "gs:// URL of the assets bucket."
  value       = module.storage.bucket_url
}

# --- IAM -------------------------------------------------------------------
output "app_service_account_email" {
  description = "Email of the application service account."
  value       = module.iam.app_sa_email
}
