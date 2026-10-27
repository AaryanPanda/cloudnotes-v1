# ---------------------------------------------------------------------------
# Storage module — outputs
# ---------------------------------------------------------------------------

output "bucket_id" {
  description = "ID of the assets bucket."
  value       = null_resource.assets_bucket.id
}

output "bucket_name" {
  description = "Name of the assets bucket (wired into compute and iam)."
  value       = var.bucket_name
}

output "bucket_url" {
  description = "gs:// URL of the bucket."
  value       = "gs://${var.bucket_name}"
}
