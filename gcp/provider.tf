variable "gcp_project" {}

provider "google" {
  credentials = file()
  project     = var.gcp_project
  region      = "us-west1"
}
