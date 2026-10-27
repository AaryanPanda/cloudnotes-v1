# ---------------------------------------------------------------------------
# Database module — outputs
# ---------------------------------------------------------------------------

output "db_instance_id" {
  description = "ID of the managed database instance."
  value       = null_resource.db_instance.id
}

output "db_instance_name" {
  description = "Name of the managed database instance."
  value       = var.db_instance_name
}

output "db_name" {
  description = "Name of the application database."
  value       = var.db_name
}

output "db_user" {
  description = "Application database user."
  value       = var.db_user
}

output "db_connection_hint" {
  description = "Shape of the connection string the app uses (no secrets)."
  value       = "postgresql://${var.db_user}@<private-ip>:5432/${var.db_name}"
}
