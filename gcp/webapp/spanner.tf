resource "google_spanner_instance" "main" {
  config       = "regional-us-east1"
  display_name = "Example Spanner Instance"
  num_nodes    = 2
  labels = {
    "repository" = "mizu0-terraform"
  }
}

resource "google_spanner_database" "database" {
  instance = google_spanner_instance.main.name
  name     = "sample"
  ddl = [
    "CREATE TABLE user (id INT64 NOT NULL, name STRING(100)) PRIMARY KEY(id)",
    "CREATE TABLE product (id INT64 NOT NULL, name STRING(100)) PRIMARY KEY(id)",
  ]
  deletion_protection = false
}
