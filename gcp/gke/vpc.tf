resource "google_compute_network" "gke_vpc" {
  name                    = "gke-tutorial-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-tutorial-subnet"
  region        = "us-east1"
  network       = google_compute_network.gke_vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
