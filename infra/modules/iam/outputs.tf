# ---------------------------------------------------------------------------
# IAM module — outputs
# ---------------------------------------------------------------------------

output "app_sa_id" {
  description = "ID of the application service account resource."
  value       = null_resource.app_sa.id
}

output "app_sa_email" {
  description = "Email of the application service account (wired into compute)."
  value       = local.sa_email
}

output "app_sa_account_id" {
  description = "Account ID of the application service account."
  value       = var.sa_account_id
}
