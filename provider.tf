terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.69.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.3.2"
    }
  }
}

provider "google" {
    credentials = "${file(var.credential_file)}"
    project = var.project_id
    region = var.region
    #zone = var.zone
}


provider "kubernetes" {
  # Configuration options
  config_path = "kubeconfig-${var.env_name}"
}