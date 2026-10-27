# ---------------------------------------------------------------------------
# Compute module — resources
#
# The application VM plus a reserved static external IP. Modeled as
# null_resource; the triggers record exactly how the real
# google_compute_instance would be configured, including the cross-module
# wiring (subnet, service account, bucket) it receives as inputs.
# ---------------------------------------------------------------------------

# --- Static external IP for the app ----------------------------------------
resource "null_resource" "app_ip" {
  triggers = {
    name         = "${var.instance_name}-ip"
    address_type = "EXTERNAL"
  }
}

# --- The CloudNotes application instance ------------------------------------
resource "null_resource" "app_instance" {
  triggers = {
    name            = var.instance_name
    project         = var.project
    zone            = var.zone
    machine_type    = var.machine_type
    image           = var.image
    subnet_id       = var.subnet_id             # from module.network
    service_account = var.service_account_email # from module.iam
    assets_bucket   = var.assets_bucket_name     # from module.storage
    external_ip     = null_resource.app_ip.id
    app_port        = var.app_port
    # Startup brings the app up under systemd (supervisord's GCE equivalent).
    startup_summary = "install python, pull app, run cloudnotes on :${var.app_port} via systemd"
  }
}
