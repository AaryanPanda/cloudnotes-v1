# ---------------------------------------------------------------------------
# IAM module — inputs
#
# A dedicated service account for the app, plus least-privilege role bindings.
# It receives the bucket name from the storage module so the object-level
# grant is scoped to exactly that bucket, not project-wide.
# ---------------------------------------------------------------------------

variable "project" {
  description = "Project identifier, used to name the service account."
  type        = string
}

variable "sa_account_id" {
  description = "Account ID (local part) of the application service account."
  type        = string
  default     = "cloudnotes-app-sa"
}

variable "sa_display_name" {
  description = "Human-readable name for the service account."
  type        = string
  default     = "CloudNotes Application Service Account"
}

# --- Wired in from the storage module --------------------------------------
variable "assets_bucket_name" {
  description = "Bucket to grant scoped object access on (module.storage.bucket_name)."
  type        = string
}
