# # Enable Cloud DNS API
# resource "google_project_service" "dns_api" {
#   project = var.project_id
#   service = "dns.googleapis.com"

#   disable_dependent_services = true
#   disable_on_destroy         = false
# }

# # Create DNS managed zone
# resource "google_dns_managed_zone" "private_zone" {
#   name        = var.dns_zone_name
#   dns_name    = var.dns_zone_domain
#   description = "Private DNS zone for internal resources"
#   project     = var.project_id

#   visibility = "private"

#   private_visibility_config {
#     networks {
#       network_url = google_compute_network.vpc.id
#     }
#   }

#   depends_on = [google_project_service.dns_api]
# }

# # Create DNS A record for Cloud SQL instance
# resource "google_dns_record_set" "cloudsql_dns" {
#   name         = var.cloudsql_hostname
#   managed_zone = google_dns_managed_zone.private_zone.name
#   type         = "A"
#   ttl          = 300
#   project      = var.project_id

#   rrdatas = [google_sql_database_instance.postgres.private_ip_address]

#   depends_on = [
#     google_dns_managed_zone.private_zone,
#     google_sql_database_instance.postgres
#   ]
# }

# # Optional: Create CNAME record for database alias
# resource "google_dns_record_set" "db_alias" {
#   count        = var.create_db_alias ? 1 : 0
#   name         = var.db_alias_name
#   managed_zone = google_dns_managed_zone.private_zone.name
#   type         = "CNAME"
#   ttl          = 300
#   project      = var.project_id

#   rrdatas = [var.cloudsql_hostname]

#   depends_on = [google_dns_record_set.cloudsql_dns]
# }