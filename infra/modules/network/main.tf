# ---------------------------------------------------------------------------
# Network module — resources
#
# VPC + three subnets + firewall rules, modeled as null_resource so that
# `terraform plan` shows the complete topology (grouped under
# module.network.*) without creating anything or costing anything.
#
# Each null_resource carries a `triggers` map that records the concrete
# attributes the equivalent GCP resource would be created with — this makes
# the plan output self-documenting: a reviewer sees the CIDRs, the network
# name and the opened ports right in the plan.
# ---------------------------------------------------------------------------

# --- VPC network -----------------------------------------------------------
resource "null_resource" "vpc" {
  triggers = {
    name                    = var.network_name
    project                 = var.project
    routing_mode            = "REGIONAL"
    auto_create_subnetworks = "false"
  }
}

# --- Subnets: web (public), app (private), db (private) --------------------
resource "null_resource" "subnet_web" {
  triggers = {
    name          = "${var.network_name}-web"
    network       = null_resource.vpc.id
    region        = var.region
    ip_cidr_range = var.web_subnet_cidr
    tier          = "web-public"
  }
}

resource "null_resource" "subnet_app" {
  triggers = {
    name                     = "${var.network_name}-app"
    network                  = null_resource.vpc.id
    region                   = var.region
    ip_cidr_range            = var.app_subnet_cidr
    tier                     = "app-private"
    private_ip_google_access = "true"
  }
}

resource "null_resource" "subnet_db" {
  triggers = {
    name                     = "${var.network_name}-db"
    network                  = null_resource.vpc.id
    region                   = var.region
    ip_cidr_range            = var.db_subnet_cidr
    tier                     = "db-private"
    private_ip_google_access = "true"
  }
}

# --- Firewall: allow the app port into the app subnet ----------------------
resource "null_resource" "fw_allow_app" {
  triggers = {
    name          = "${var.network_name}-allow-app"
    network       = null_resource.vpc.id
    direction     = "INGRESS"
    allow         = "tcp:${var.app_port}"
    source_ranges = "0.0.0.0/0"
    target_subnet = null_resource.subnet_app.id
  }
}

# --- Firewall: allow SSH for administration --------------------------------
resource "null_resource" "fw_allow_ssh" {
  triggers = {
    name          = "${var.network_name}-allow-ssh"
    network       = null_resource.vpc.id
    direction     = "INGRESS"
    allow         = "tcp:22"
    source_ranges = "0.0.0.0/0"
  }
}

# --- Firewall: allow internal app -> db traffic only -----------------------
resource "null_resource" "fw_allow_db_internal" {
  triggers = {
    name          = "${var.network_name}-allow-db-internal"
    network       = null_resource.vpc.id
    direction     = "INGRESS"
    allow         = "tcp:5432"
    source_ranges = var.app_subnet_cidr
    target_subnet = null_resource.subnet_db.id
  }
}
