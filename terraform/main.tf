resource "google_project_service" "cloud-run-api" {
  service                    = "run.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "compute-api" {
  service                    = "compute.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "vpcaccess-api" {
  service                    = "vpcaccess.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_vpc_access_connector" "vpcaccess-connector" {
  depends_on = [google_project_service.vpcaccess-api]
  name       = "run-vpc"
  subnet {
    name = google_compute_subnetwork.run-subnetwork.name
  }
  machine_type  = "e2-standard-4"
  min_instances = 2
  max_instances = 3
}
resource "google_compute_network" "run-network" {
  depends_on              = [google_project_service.compute-api]
  name                    = "run-network"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "run-subnetwork" {
  name          = "run-subnetwork"
  ip_cidr_range = "10.2.0.0/28"
  network = google_compute_network.run-network.id
}

resource "google_cloud_run_v2_service" "default" {
  depends_on = [google_project_service.cloud-run-api]
  name       = "cloudrun-service"
  location   = var.region
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    vpc_access {
      connector = google_vpc_access_connector.vpcaccess-connector.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

/*
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
*/