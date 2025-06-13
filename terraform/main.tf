# Terraform file with GKE and Helm deployment

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc_network" {
  name = "gke-vpc"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# GKE Cluster (control plane)
resource "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = var.region

  deletion_protection = false

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

# Node Pool (worker nodes)
resource "google_container_node_pool" "primary_nodes" {
  name     = "primary-node-pool"
  cluster  = google_container_cluster.gke_cluster.name
  location = var.region

  node_count = 2

  node_config {
    machine_type = "e2-medium"
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
  }
}

# Helm provider and releases
provider "helm" {
  kubernetes {
    host                   = google_container_cluster.gke_cluster.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  }
}

data "google_client_config" "default" {}

resource "helm_release" "web" {
  name       = "web"
  chart      = "./web-0.1.0.tgz"
  namespace  = "default"
}

resource "helm_release" "api" {
  name       = "api"
  chart      = "./api-0.1.0.tgz"
  namespace  = "default"
}

resource "helm_release" "mysql" {
  name       = "mysql"
  chart      = "./mysql-0.1.0.tgz"
  namespace  = "default"
}


