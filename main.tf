terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Storage bucket for website assets and community resources
resource "google_storage_bucket" "vht_learning_bucket" {
  name          = var.bucket_name
  location      = var.gcp_region
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    project     = "vht-learning-platform"
    author      = "Charles Herbert Matovu"
    environment = var.environment
  }
}
