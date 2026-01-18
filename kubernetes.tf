# Google Kubernetes Engine Cluster Configuration
# Creates a 3-node K8s cluster for VHT Community Learning Platform

resource "google_container_cluster" "vht_k8s_cluster" {
  name     = "${var.cluster_name}-${var.environment}"
  location = var.gcp_region
  project  = var.gcp_project_id

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vht_network.name
  subnetwork = google_compute_subnetwork.vht_subnet.name

  # Cluster settings
  enable_shielded_nodes = true
  networking_mode       = "VPC_NATIVE"

  # IP allocation policy for VPC-native networking
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Security
  network_policy {
    enabled  = true
    provider = "PROVIDER_UNSPECIFIED"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  resource_labels = {
    project     = "vht-learning-platform"
    author      = "charles-herbert-matovu"
    environment = var.environment
    created_by  = "terraform"
  }
}

# Node pool with 3 nodes
resource "google_container_node_pool" "vht_node_pool" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.vht_k8s_cluster.name
  node_count = var.kubernetes_node_count
  project    = var.gcp_project_id

  autoscaling {
    min_node_count = var.kubernetes_node_count
    max_node_count = var.kubernetes_max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.kubernetes_preemptible
    machine_type = var.kubernetes_machine_type
    disk_type    = "pd-standard"
    disk_size_gb = 50

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = {
      project     = "vht-learning-platform"
      environment = var.environment
    }

    tags = ["vht-platform-node", var.environment]
  }

  depends_on = [
    google_container_cluster.vht_k8s_cluster
  ]
}

# VPC Network
resource "google_compute_network" "vht_network" {
  name                    = "${var.cluster_name}-network"
  project                 = var.gcp_project_id
  auto_create_subnetworks = false

  depends_on = []
}

# Subnet
resource "google_compute_subnetwork" "vht_subnet" {
  name          = "${var.cluster_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vht_network.id
  project       = var.gcp_project_id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = "https://${google_container_cluster.vht_k8s_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.vht_k8s_cluster.master_auth[0].cluster_ca_certificate)
}

# Get current GCP configuration
data "google_client_config" "default" {}
