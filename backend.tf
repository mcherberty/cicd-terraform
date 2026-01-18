provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.credentials_path != "" ? file(var.credentials_path) : null
}

# terraform {
#   backend "gcs" {
#     bucket = "vht-terraform-state"
#     prefix = "terraform/state"
#   }
# }
