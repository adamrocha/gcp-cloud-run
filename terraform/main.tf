resource "google_project_service" "cloud-run-api" {
  service                    = "run.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_cloud_run_v2_service" "default" {
  depends_on = [google_project_service.cloud-run-api]
  name       = "cloudrun-service"
  location   = var.region
  ingress    = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}