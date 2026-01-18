output "bucket_name" {
  description = "Name of the created GCS bucket"
  value       = google_storage_bucket.vht_learning_bucket.name
}

output "bucket_url" {
  description = "URL of the GCS bucket"
  value       = "gs://${google_storage_bucket.vht_learning_bucket.name}"
}

output "bucket_self_link" {
  description = "Self link of the GCS bucket"
  value       = google_storage_bucket.vht_learning_bucket.self_link
}

output "bucket_location" {
  description = "Location of the GCS bucket"
  value       = google_storage_bucket.vht_learning_bucket.location
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.gcp_project_id
}

output "region" {
  description = "GCP Region"
  value       = var.gcp_region
}
