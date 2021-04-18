variable "gcp_project" {}

provider "google" {
  project     = var.gcp_project
  region      = "us-west1"
}
