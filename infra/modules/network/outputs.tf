# ---------------------------------------------------------------------------
# Network module — outputs
#
# These are the handles other modules wire themselves to: compute attaches to
# app_subnet_id, database attaches to db_subnet_id. Re-exposing them here is
# what makes outputs -> inputs composition possible at the root.
# ---------------------------------------------------------------------------

output "network_id" {
  description = "ID of the VPC network."
  value       = null_resource.vpc.id
}

output "network_name" {
  description = "Name of the VPC network."
  value       = var.network_name
}

output "web_subnet_id" {
  description = "ID of the public web subnet."
  value       = null_resource.subnet_web.id
}

output "app_subnet_id" {
  description = "ID of the private app subnet (where the VM runs)."
  value       = null_resource.subnet_app.id
}

output "db_subnet_id" {
  description = "ID of the private database subnet."
  value       = null_resource.subnet_db.id
}

output "app_subnet_cidr" {
  description = "CIDR of the app subnet (reused by the DB firewall rule)."
  value       = var.app_subnet_cidr
}
