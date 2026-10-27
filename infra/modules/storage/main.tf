# ---------------------------------------------------------------------------
# Storage module — resources
#
# The assets bucket, modeled as null_resource. The triggers record the bucket
# configuration the real google_storage_bucket would carry. Access is granted
# in the iam module (least privilege), not here, keeping this module purely
# about the bucket itself.
# ---------------------------------------------------------------------------

resource "null_resource" "assets_bucket" {
  triggers = {
    name                        = var.bucket_name
    project                     = var.project
    location                    = var.region
    storage_class               = var.storage_class
    versioning                  = tostring(var.versioning_enabled)
    uniform_bucket_level_access = "true"   # IAM-only access, no legacy ACLs
    public_access_prevention    = "enforced"
  }
}
