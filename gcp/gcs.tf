#先に作成
resource "google_storage_bucket" "tfstate" {
  name     = "mizu0-tfstate"
  location = "us-west1"
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}