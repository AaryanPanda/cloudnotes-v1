# ---------------------------------------------------------------------------
# Storage module — inputs
#
# A Cloud Storage bucket for CloudNotes assets and user uploads (the cloud
# home of the local uploads/ directory).
# ---------------------------------------------------------------------------

variable "project" {
  description = "Project identifier, used to name the bucket."
  type        = string
}

variable "region" {
  description = "Location the bucket is created in."
  type        = string
}

variable "bucket_name" {
  description = "Globally-unique name of the assets bucket."
  type        = string
}

variable "storage_class" {
  description = "Storage class for the bucket."
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  description = "Whether object versioning is enabled."
  type        = bool
  default     = true
}
