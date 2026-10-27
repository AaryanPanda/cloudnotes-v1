# ===========================================================================
# ROOT — the complete CloudNotes system, composed from five modules
# ===========================================================================
#
# Dependency order (Terraform resolves this automatically from the references
# below, but it helps to see it):
#
#   network ──┬─> compute   (app VM sits in network.app_subnet)
#             └─> database  (DB sits in network.db_subnet)
#   storage ──┬─> iam       (SA granted scoped access to storage.bucket)
#             └─> compute   (VM told which bucket to use)
#   iam ──────> compute     (VM runs as iam.app_sa)
#
# The wiring below is the whole point of the capstone: every `= module.X.Y`
# is one module's output feeding another module's input.
# ===========================================================================

# --- Layer 1: Network ------------------------------------------------------
# VPC, three subnets (web/app/db), firewall rules. Depends on nothing.
module "network" {
  source = "./modules/network"

  project         = var.project
  region          = var.region
  network_name    = var.network_name
  web_subnet_cidr = var.web_subnet_cidr
  app_subnet_cidr = var.app_subnet_cidr
  db_subnet_cidr  = var.db_subnet_cidr
  app_port        = var.app_port
}

# --- Layer 2: Storage ------------------------------------------------------
# Assets bucket. Independent of network; IAM scopes access to it next.
module "storage" {
  source = "./modules/storage"

  project     = var.project
  region      = var.region
  bucket_name = var.assets_bucket_name
}

# --- Layer 3: IAM ----------------------------------------------------------
# Service account + least-privilege bindings.
# WIRED: storage.bucket_name -> iam.assets_bucket_name (scoped grant).
module "iam" {
  source = "./modules/iam"

  project            = var.project
  assets_bucket_name = module.storage.bucket_name # outputs -> inputs
}

# --- Layer 4: Database -----------------------------------------------------
# Managed PostgreSQL on the private db subnet.
# WIRED: network.db_subnet_id -> database.private_subnet_id.
module "database" {
  source = "./modules/database"

  project           = var.project
  region            = var.region
  db_instance_name  = var.db_instance_name
  db_tier           = var.db_tier
  private_subnet_id = module.network.db_subnet_id # outputs -> inputs
}

# --- Layer 5: Compute ------------------------------------------------------
# The app VM. This is where the most wiring converges:
# WIRED: network.app_subnet_id -> compute.subnet_id
# WIRED: iam.app_sa_email       -> compute.service_account_email
# WIRED: storage.bucket_name    -> compute.assets_bucket_name
module "compute" {
  source = "./modules/compute"

  project               = var.project
  zone                  = var.zone
  machine_type          = var.machine_type
  instance_name         = var.instance_name
  app_port              = var.app_port
  subnet_id             = module.network.app_subnet_id  # outputs -> inputs
  service_account_email = module.iam.app_sa_email        # outputs -> inputs
  assets_bucket_name    = module.storage.bucket_name      # outputs -> inputs
}
