# ---------------------------------------------------------------------------
# Database module — inputs
#
# Managed PostgreSQL (Cloud SQL in the real world), attached to the private
# db subnet so it is never exposed publicly. The subnet arrives from the
# network module via the root.
# ---------------------------------------------------------------------------

variable "project" {
  description = "Project identifier, used to name the DB instance."
  type        = string
}

variable "region" {
  description = "Region the database runs in."
  type        = string
}

variable "db_instance_name" {
  description = "Name of the managed database instance."
  type        = string
  default     = "cloudnotes-db"
}

variable "db_name" {
  description = "Name of the application database."
  type        = string
  default     = "cloudnotes"
}

variable "db_version" {
  description = "Database engine version."
  type        = string
  default     = "POSTGRES_15"
}

variable "db_tier" {
  description = "Machine tier for the managed DB."
  type        = string
  default     = "db-f1-micro"
}

variable "db_user" {
  description = "Application database user."
  type        = string
  default     = "cloudnotes_app"
}

# --- Wired in from the network module --------------------------------------
variable "private_subnet_id" {
  description = "ID of the private db subnet (module.network.db_subnet_id)."
  type        = string
}
