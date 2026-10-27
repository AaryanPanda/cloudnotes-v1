# ---------------------------------------------------------------------------
# Root variables — the single place environment-specific values are declared
#
# The modules are kept generic; everything that would change between
# environments (project, region, CIDRs, names, sizes) is declared here and
# passed down. Defaults are provided so `terraform plan` runs with no tfvars,
# but a real environment would supply terraform.tfvars (see the .example).
# ---------------------------------------------------------------------------

variable "project" {
  description = "Project identifier for all CloudNotes resources."
  type        = string
  default     = "cloudnotes-dev"
}

variable "region" {
  description = "Region all regional resources are created in."
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "Zone the application VM runs in."
  type        = string
  default     = "asia-south1-a"
}

# --- Network CIDRs ---------------------------------------------------------
variable "web_subnet_cidr" {
  description = "CIDR for the public web subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "app_subnet_cidr" {
  description = "CIDR for the private app subnet (VM lives here)."
  type        = string
  default     = "10.10.1.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR for the private database subnet."
  type        = string
  default     = "10.10.2.0/24"
}

# --- Naming ----------------------------------------------------------------
variable "network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = "cloudnotes-vpc"
}

variable "instance_name" {
  description = "Name of the application VM."
  type        = string
  default     = "cloudnotes-app"
}

variable "db_instance_name" {
  description = "Name of the managed database instance."
  type        = string
  default     = "cloudnotes-db"
}

variable "assets_bucket_name" {
  description = "Globally-unique name of the assets bucket."
  type        = string
  default     = "cloudnotes-dev-assets"
}

# --- Sizing ----------------------------------------------------------------
variable "machine_type" {
  description = "Machine type for the app VM."
  type        = string
  default     = "e2-medium"
}

variable "db_tier" {
  description = "Machine tier for the managed DB."
  type        = string
  default     = "db-f1-micro"
}

variable "app_port" {
  description = "Port the CloudNotes app serves on."
  type        = number
  default     = 5000
}
