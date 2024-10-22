terraform {
  backend "gcs" {
    bucket = "terraform-state-124"
  }
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "~> 1.0" # Use the latest version or specify a version constraint
    }
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "google" {
  project = "black-leg-sanji"
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

