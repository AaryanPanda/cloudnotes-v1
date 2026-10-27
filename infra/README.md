# CloudNotes — Full Infrastructure as Terraform

This directory is the complete CloudNotes system expressed as a single,
version-controlled Terraform configuration: a root that composes five modules
(network, compute, database, storage, IAM), validated locally at **zero cost**.

## Layout

```
infra/
├── providers.tf              # null provider — zero cost, no cloud account
├── variables.tf              # root inputs (project, region, CIDRs, names, sizes)
├── main.tf                   # ROOT: composes all five modules, wired together
├── outputs.tf                # system outputs (app URL, bucket, DB, SA email)
├── terraform.tfvars.example  # example environment values (no secrets)
└── modules/
    ├── network/              # VPC, 3 subnets (web/app/db), firewall rules
    ├── compute/              # the CloudNotes app VM + static IP
    ├── database/             # managed PostgreSQL + app DB + app user
    ├── storage/              # assets bucket
    └── iam/                  # service account + least-privilege bindings
```

## The five layers

| Module    | What it provisions                                                         |
|-----------|-----------------------------------------------------------------------------|
| network   | A VPC, three subnets (public web, private app, private db), and firewall rules opening the app port and SSH, plus an internal-only app→db rule. |
| compute   | The CloudNotes application VM in the **app** subnet, a reserved external IP, running as the app service account. |
| database  | A managed PostgreSQL instance on the **private db** subnet (no public IP), the `cloudnotes` database, and the app DB user. |
| storage   | A Cloud Storage bucket for assets/uploads, with uniform access and public-access prevention. |
| iam       | A dedicated service account with **least-privilege** bindings: bucket-scoped object access, Cloud SQL client, Secret Manager accessor. |

## How the modules wire together (outputs → inputs)

```
module.storage.bucket_name     ─> module.iam.assets_bucket_name     (scoped grant)
module.storage.bucket_name     ─> module.compute.assets_bucket_name
module.network.db_subnet_id    ─> module.database.private_subnet_id
module.network.app_subnet_id   ─> module.compute.subnet_id
module.iam.app_sa_email        ─> module.compute.service_account_email
```

## Zero-cost validation

Everything is modeled with the `null` provider, so the design validates and
plans with **no cloud account, no credentials, and no spend**. Each
`null_resource` carries a `triggers` map documenting the exact attributes the
equivalent GCP resource (`google_compute_network`, `google_compute_instance`,
`google_sql_database_instance`, `google_storage_bucket`,
`google_service_account`, …) would be created with, so the plan reads as a
blueprint of the real system.

```bash
cd infra
terraform init       # links the five modules + installs the null provider
terraform validate   # => "Success! The configuration is valid."
terraform plan       # the complete system, grouped by module.NAME.*, all "to add"
# Do NOT run terraform apply — the capstone proves the design at zero cost.
```

## Moving to real GCP later

The module boundaries, variable surface, and output wiring are already in the
shape a real deployment needs. Swapping to the live `google` provider is
mechanical: replace each `null_resource` with its `google_*` equivalent and
add a `google` provider block with project/region in `providers.tf`. Nothing
about the composition changes.
