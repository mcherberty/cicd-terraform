variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gcp_project_id))
    error_message = "GCP project ID must be valid."
  }
}

variable "gcp_region" {
  description = "GCP Region for resources"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Name of the GCS bucket for VHT learning platform"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be valid GCS bucket name (3-63 chars, lowercase, hyphens allowed)."
  }
}

variable "credentials_path" {
  description = "Path to GCP service account credentials JSON file"
  type        = string
  default     = ""
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "force_destroy" {
  description = "Allow destruction of bucket with contents"
  type        = bool
  default     = true
  sensitive   = false
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Additional labels for resources"
  type        = map(string)
  default = {
    author       = "Charles Herbert Matovu"
    created_year = "2025"
    project_type = "community-learning-platform"
  }
}

# Kubernetes Configuration Variables
variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "vht-learning-platform"
}

variable "kubernetes_node_count" {
  description = "Number of nodes in the Kubernetes cluster"
  type        = number
  default     = 3
  validation {
    condition     = var.kubernetes_node_count >= 3 && var.kubernetes_node_count <= 10
    error_message = "Kubernetes node count must be between 3 and 10."
  }
}

variable "kubernetes_max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 9
}

variable "kubernetes_machine_type" {
  description = "Machine type for Kubernetes nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "kubernetes_preemptible" {
  description = "Use preemptible nodes (cheaper but less reliable)"
  type        = bool
  default     = false
}

variable "docker_image_registry" {
  description = "Docker registry URL"
  type        = string
  default     = "gcr.io"
}

variable "docker_image_name" {
  description = "Docker image name"
  type        = string
  default     = "vht-platform"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
