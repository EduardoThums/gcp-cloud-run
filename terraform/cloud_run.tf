# Enable required APIs
resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "cloud_run_api" {
  project = var.project_id
  service = "run.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id

  depends_on = [google_project_service.compute_api]

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

# Subnet 1
resource "google_compute_subnetwork" "subnet_1" {
  name          = "${var.vpc_name}-subnet-1"
  ip_cidr_range = var.subnet_1_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
  stack_type    = "IPV4_ONLY"

  depends_on = [google_compute_network.vpc]

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

# Subnet 2
# resource "google_compute_subnetwork" "subnet_2" {
#   name          = "${var.vpc_name}-subnet-2"
#   ip_cidr_range = var.subnet_2_cidr
#   region        = var.region
#   network       = google_compute_network.vpc.id
#   project       = var.project_id
#   stack_type    = "IPV4_ONLY"
#   depends_on    = [google_compute_network.vpc]
# }

# Cloud Run v2 Service
resource "google_cloud_run_v2_service" "default" {
  # depends_on = [google_project_service.cloud_run_api]

  name     = var.service_name
  location = var.region
  project  = var.project_id
  # uri = null

  template {
    containers {
      image = var.container_image

      ports {
        container_port = var.container_port
      }

      #   env {
      #     name  = "PORT"
      #     value = tostring(var.container_port)
      #   }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # Direct VPC networking configuration
    vpc_access {
      network_interfaces {
        network    = google_compute_network.vpc.id
        subnetwork = google_compute_subnetwork.subnet_1.id
        tags       = ["cloud-run-service"]
      }
      egress = "PRIVATE_RANGES_ONLY"
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [
    google_project_service.cloud_run_api,
    google_compute_subnetwork.subnet_1,
    # google_compute_subnetwork.subnet_2
  ]
}

# Get project data for service account
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# resource "google_cloud_run_v2_service_iam_member" "public_access" {
#   name   = google_cloud_run_v2_service.default.name
#   location = google_cloud_run_v2_service.default.location
#   role   = "roles/run.invoker"
#   member = "allUsers"
# }



# # IAM policy to allow load balancer access to Cloud Run
# resource "google_cloud_run_v2_service_iam_binding" "load_balancer_invoker" {
#   project  = google_cloud_run_v2_service.default.project
#   location = google_cloud_run_v2_service.default.location
#   name     = google_cloud_run_v2_service.default.name
#   role     = "roles/run.invoker"
#   members = [
#     "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
#   ]
# }

# # Get project data for service account
# data "google_project" "project" {
#   project_id = var.project_id
# }

# # Optional: IAM policy to allow unauthenticated access (only if not using load balancer)
# resource "google_cloud_run_v2_service_iam_binding" "public_access" {
#   count = var.allow_unauthenticated && var.enable_public_access ? 1 : 0

#   project  = google_cloud_run_v2_service.default.project
#   location = google_cloud_run_v2_service.default.location
#   name     = google_cloud_run_v2_service.default.name
#   role     = "roles/run.invoker"
#   members = [
#     "allUsers"
#   ]
# }