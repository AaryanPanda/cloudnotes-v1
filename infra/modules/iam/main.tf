# ---------------------------------------------------------------------------
# IAM module — resources
#
# One service account for the app, and least-privilege role bindings:
#   - objectAdmin scoped to the assets bucket (read/write uploads)
#   - cloudsql.client (connect to the managed DB, no admin)
#   - secretmanager.secretAccessor (read the DB password / secret key)
# Modeled as null_resource; the triggers record the member and role of each
# binding so the grants are visible in the plan.
# ---------------------------------------------------------------------------

locals {
  sa_email = "${var.sa_account_id}@${var.project}.iam.gserviceaccount.com"
}

# --- The application service account ----------------------------------------
resource "null_resource" "app_sa" {
  triggers = {
    account_id   = var.sa_account_id
    display_name = var.sa_display_name
    project      = var.project
    email        = local.sa_email
  }
}

# --- Bucket-scoped object access (least privilege) -------------------------
resource "null_resource" "binding_bucket" {
  triggers = {
    member = "serviceAccount:${local.sa_email}"
    role   = "roles/storage.objectAdmin"
    scope  = "bucket:${var.assets_bucket_name}" # scoped, not project-wide
  }
}

# --- Cloud SQL client (connect only, no admin) -----------------------------
resource "null_resource" "binding_cloudsql" {
  triggers = {
    member = "serviceAccount:${local.sa_email}"
    role   = "roles/cloudsql.client"
    scope  = "project:${var.project}"
  }
}

# --- Secret Manager accessor (read secrets at runtime) ---------------------
resource "null_resource" "binding_secrets" {
  triggers = {
    member = "serviceAccount:${local.sa_email}"
    role   = "roles/secretmanager.secretAccessor"
    scope  = "project:${var.project}"
  }
}
