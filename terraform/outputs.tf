output "service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.default.uri
}

output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_v2_service.default.name
}

output "service_location" {
  description = "The location of the Cloud Run service"
  value       = google_cloud_run_v2_service.default.location
}

# VPC Outputs
output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "subnet_1_name" {
  description = "The name of the first subnet"
  value       = google_compute_subnetwork.subnet_1.name
}

output "subnet_1_cidr" {
  description = "The CIDR block of the first subnet"
  value       = google_compute_subnetwork.subnet_1.ip_cidr_range
}

# output "subnet_2_name" {
#   description = "The name of the second subnet"
#   value       = google_compute_subnetwork.subnet_2.name
# }

# output "subnet_2_cidr" {
#   description = "The CIDR block of the second subnet"
#   value       = google_compute_subnetwork.subnet_2.ip_cidr_range
# }

# Cloud SQL Outputs
# output "cloudsql_connection_name" {
#   description = "The connection name of the Cloud SQL instance"
#   value       = google_sql_database_instance.postgres.connection_name
# }

# output "cloudsql_private_ip" {
#   description = "The private IP address of the Cloud SQL instance"
#   value       = google_sql_database_instance.postgres.private_ip_address
# }

# output "database_name" {
#   description = "The name of the created database"
#   value       = google_sql_database.database.name
# }

# output "database_user" {
#   description = "The database user name"
#   value       = google_sql_user.user.name
#   sensitive   = false
# }

# output "database_password" {
#   description = "The generated database password"
#   value       = random_password.db_password.result
#   sensitive   = true
# }

# DNS Outputs
# output "dns_zone_name" {
#   description = "The name of the DNS managed zone"
#   value       = google_dns_managed_zone.private_zone.name
# }

# output "dns_zone_domain" {
#   description = "The DNS domain of the managed zone"
#   value       = google_dns_managed_zone.private_zone.dns_name
# }

# output "cloudsql_hostname" {
#   description = "The hostname for accessing the Cloud SQL instance"
#   value       = var.cloudsql_hostname
# }

# output "cloudsql_hostname_without_dot" {
#   description = "The hostname for Cloud SQL without trailing dot"
#   value       = trimsuffix(var.cloudsql_hostname, ".")
# }

# output "db_alias_hostname" {
#   description = "The database alias hostname (if created)"
#   value       = var.create_db_alias ? trimsuffix(var.db_alias_name, ".") : null
# }

# Load Balancer Outputs
# output "load_balancer_ip" {
#   description = "The external IP address of the load balancer"
#   value       = google_compute_global_address.lb_ip.address
# }

# output "load_balancer_domain" {
#   description = "The domain name configured for the load balancer"
#   value       = var.domain_name
# }

# output "storage_bucket_name" {
#   description = "The name of the storage bucket for static content"
#   value       = google_storage_bucket.static_content.name
# }

# output "storage_bucket_url" {
#   description = "The URL of the storage bucket"
#   value       = google_storage_bucket.static_content.url
# }

# output "ssl_certificate_status" {
#   description = "The status of the SSL certificate"
#   value       = google_compute_managed_ssl_certificate.lb_ssl_cert.managed[0].status
# }

# Edge Function Outputs (2nd Generation)
output "edge_function_url" {
  description = "URL of the storage authentication edge function (2nd gen)"
  value       = google_cloudfunctions2_function.storage_auth_edge.service_config[0].uri
}

output "edge_function_name" {
  description = "Name of the deployed edge function (2nd gen)"
  value       = google_cloudfunctions2_function.storage_auth_edge.name
}

output "edge_function_location" {
  description = "Location of the deployed edge function"
  value       = google_cloudfunctions2_function.storage_auth_edge.location
}

output "cloud_function_backend_name" {
  description = "Name of the Cloud Function backend service"
  value       = google_compute_backend_service.cloud_function_backend.name
}

output "load_balancer_routing" {
  description = "Load balancer routing configuration"
  value = {
    default_service = "Cloud Function (Authenticated Storage)"
    api_service     = "Cloud Run Application"
    domain          = var.domain_name
  }
}

