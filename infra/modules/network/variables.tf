# ---------------------------------------------------------------------------
# Network module — inputs
#
# Models the CloudNotes VPC: one network, three subnets (web / app / db) and
# the firewall rules that control ingress. Written against the null provider
# so the whole design validates and plans at zero cost, but the variable
# surface mirrors what a real google_compute_network / _subnetwork / _firewall
# stack would take, so swapping in the google provider later is mechanical.
# ---------------------------------------------------------------------------

variable "project" {
  description = "Project identifier, used to name network resources."
  type        = string
}

variable "region" {
  description = "Region the subnets live in (e.g. asia-south1)."
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = "cloudnotes-vpc"
}

variable "web_subnet_cidr" {
  description = "CIDR range for the public web subnet."
  type        = string
}

variable "app_subnet_cidr" {
  description = "CIDR range for the private app subnet (hosts the VM)."
  type        = string
}

variable "db_subnet_cidr" {
  description = "CIDR range for the private database subnet."
  type        = string
}

variable "app_port" {
  description = "TCP port the CloudNotes app listens on (opened by firewall)."
  type        = number
  default     = 5000
}
