# # # Enable Cloud SQL API
# resource "google_project_service" "sql_api" {
#   project = var.project_id
#   service = "sqladmin.googleapis.com"

#   disable_dependent_services = true
#   disable_on_destroy         = false
# }

# # # Enable Service Networking API (required for private IP)
resource "google_project_service" "servicenetworking_api" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# # # Generate random password for Cloud SQL instance
# resource "random_password" "db_password" {
#   length  = 16
#   special = false
#   upper   = true
#   lower   = true
#   numeric = true
# }

# # # Reserve IP range for private services access
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.cloudsql_instance_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpc.id
  project       = var.project_id

  depends_on = [google_project_service.servicenetworking_api, google_compute_network.vpc]

}

# # Create private connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  depends_on = [google_compute_global_address.private_ip_alloc]
}

# # Cloud SQL PostgreSQL instance
# resource "google_sql_database_instance" "postgres" {
#   name             = var.cloudsql_instance_name
#   database_version = var.postgres_version
#   region           = var.region
#   project          = var.project_id

#   settings {
#     tier              = var.cloudsql_tier
#     availability_type = "ZONAL"
#     disk_type         = "PD_HDD"
#     disk_size         = var.cloudsql_disk_size
#       edition          = "ENTERPRISE"

#     location_preference {
#       zone = var.zone
#     }

#     ip_configuration {
#       ipv4_enabled                                  = false
#       private_network                               = google_compute_network.vpc.id
#       enable_private_path_for_google_cloud_services = false
#     }

#     backup_configuration {
#       enabled                        = true
#       start_time                     = "03:00"
#       point_in_time_recovery_enabled = true
#       location                       = var.region
#     }

#     maintenance_window {
#       day          = 7
#       hour         = 4
#       update_track = "stable"
#     }
#   }

#   deletion_protection = false

#   depends_on = [
#     google_project_service.sql_api,
#     google_service_networking_connection.private_vpc_connection
#   ]
# }

# # Create database
# resource "google_sql_database" "database" {
#   name     = var.database_name
#   instance = google_sql_database_instance.postgres.name
#   project  = var.project_id
# }

# # Create database user
# resource "google_sql_user" "user" {
#   name     = var.database_user
#   instance = google_sql_database_instance.postgres.name
#   password = random_password.db_password.result
#   project  = var.project_id
# }