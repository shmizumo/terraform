variable "gcp_project" {}

provider "google" {
  project = var.gcp_project
  region  = "us-west1"
}

terraform {
  backend "gcs" {
    bucket = "mizu0-tfstate"
    prefix = "gke"
  }
}