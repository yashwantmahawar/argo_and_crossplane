

data "google_client_config" "default" {}
resource "google_storage_bucket" "terraform-backend" {
  name          = "terraform-backend-5656"
  location      = "us-central1"
  force_destroy = true

}

resource "google_service_account" "gke-sa" {
  account_id   = "gke-operations-sa"
  display_name = "gke operations service account"
}

resource "google_container_cluster" "primary" {
  name                     = "my-gke-cluster"
  location                 = "asia-south1"
  network                  = "blackleg-vpc"
  subnetwork               = "blackleg-mumbai"
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "asia-south1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke-sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}