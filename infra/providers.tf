# ---------------------------------------------------------------------------
# Providers — zero-cost validation
#
# The entire CloudNotes system is modeled against the `null` provider. This
# lets `terraform init`, `validate`, and `plan` run with NO cloud account, NO
# credentials, and NO spend — the capstone proves the design is correct before
# any real provisioning. Resources are expressed as null_resource whose
# `triggers` maps document the concrete attributes each real GCP resource
# (google_compute_network, google_compute_instance, google_sql_database_instance,
# google_storage_bucket, google_service_account, ...) would be created with.
#
# Swapping to the real google provider later is a mechanical change: replace
# the null_resource blocks with their google_* equivalents and add a
# `google` provider block here with project/region. The module boundaries,
# variable surface, and output wiring stay exactly as they are.
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "null" {
  # The null provider takes no configuration — nothing to authenticate,
  # nothing to bill.
}
