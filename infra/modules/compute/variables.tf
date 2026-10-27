# ---------------------------------------------------------------------------
# Compute module — inputs
#
# The CloudNotes application VM (a Compute Engine instance in the real world).
# It is placed in the app subnet and runs as the application service account,
# both of which arrive as inputs from other modules via the root.
# ---------------------------------------------------------------------------

variable "project" {
  description = "Project identifier, used to name the instance."
  type        = string
}

variable "zone" {
  description = "Zone the VM runs in (e.g. asia-south1-a)."
  type        = string
}

variable "machine_type" {
  description = "Machine type for the app VM."
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "Boot image for the VM."
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "instance_name" {
  description = "Name of the application instance."
  type        = string
  default     = "cloudnotes-app"
}

# --- Wired in from the network module --------------------------------------
variable "subnet_id" {
  description = "ID of the app subnet this VM attaches to (module.network.app_subnet_id)."
  type        = string
}

# --- Wired in from the iam module ------------------------------------------
variable "service_account_email" {
  description = "Service account the VM runs as (module.iam.app_sa_email)."
  type        = string
}

# --- Wired in from the storage module --------------------------------------
variable "assets_bucket_name" {
  description = "Bucket the app reads/writes assets from (module.storage.bucket_name)."
  type        = string
}

variable "app_port" {
  description = "Port the app serves on."
  type        = number
  default     = 5000
}
