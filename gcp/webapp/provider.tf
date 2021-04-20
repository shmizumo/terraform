variable "gcp_project" {}

provider "google" {
  project = var.gcp_project
  region  = "asia-northeast1"
}

terraform {
  backend "gcs" {
    bucket = "mizu0-tfstate"
    prefix = "webapp"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.64.0"
    }
  }

  required_version = "~> 0.14"
}
