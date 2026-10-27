# ---------------------------------------------------------------------------
# Compute module — outputs
# ---------------------------------------------------------------------------

output "instance_id" {
  description = "ID of the application instance."
  value       = null_resource.app_instance.id
}

output "instance_name" {
  description = "Name of the application instance."
  value       = var.instance_name
}

output "app_ip_id" {
  description = "ID of the reserved external IP for the app."
  value       = null_resource.app_ip.id
}

output "app_url" {
  description = "URL the app is reachable at (external IP + port)."
  value       = "http://<${var.instance_name}-ip>:${var.app_port}"
}
