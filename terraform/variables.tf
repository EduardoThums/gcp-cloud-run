variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "leafy-tractor-467821-g6"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
  default     = "my-cloud-run-app"
}

variable "container_image" {
  description = "The Docker image to deploy"
  type        = string
  default     = "docker.io/eduardothums/cloud-run-python:20ad72d7-cfda-49bb-86c5-0f0f5120ddb4"
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for the container"
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated access to the service"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable direct public access to Cloud Run (disable when using load balancer)"
  type        = bool
  default     = false
}

# VPC Variables
variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "main-vpc"
}

variable "subnet_1_cidr" {
  description = "CIDR block for the first subnet"
  type        = string
  default     = "10.0.0.0/20"
}

# variable "subnet_2_cidr" {
#   description = "CIDR block for the second subnet"
#   type        = string
#   default     = "10.0.16.0/20"
# }

# Cloud SQL Variables
variable "cloudsql_instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
  default     = "postgres-instance"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_17"
}

variable "cloudsql_tier" {
  description = "The machine type for Cloud SQL instance (sandbox tier)"
  type        = string
  default     = "db-f1-micro"
}

variable "cloudsql_disk_size" {
  description = "The disk size for Cloud SQL instance in GB"
  type        = number
  default     = 10
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
  default     = "app_database"
}

variable "database_user" {
  description = "The database user name"
  type        = string
  default     = "app_user"
}

# # DNS Variables
# variable "dns_zone_name" {
#   description = "The name of the DNS managed zone"
#   type        = string
#   default     = "private-zone"
# }

# variable "dns_zone_domain" {
#   description = "The DNS domain for the managed zone (must end with .)"
#   type        = string
#   default     = "internal.local."
# }

# variable "cloudsql_hostname" {
#   description = "The hostname for the Cloud SQL instance"
#   type        = string
#   default     = "postgres.internal.local."
# }

# variable "create_db_alias" {
#   description = "Whether to create a database alias CNAME record"
#   type        = bool
#   default     = false
# }

# variable "db_alias_name" {
#   description = "The alias name for the database (CNAME record)"
#   type        = string
#   default     = "db.internal.local."
# }

# Load Balancer Variables
variable "domain_name" {
  description = "The domain name for the load balancer"
  type        = string
  default     = "example.iowqoeywqoeysoadyoasdyoasdyasodiyasod.uk"
}

variable "bucket_name" {
  description = "The name of the storage bucket for static content"
  type        = string
  default     = "your-project-static-content"
}

variable "lb_ip_name" {
  description = "The name of the load balancer IP address"
  type        = string
  default     = "lb-external-ip"
}

variable "ssl_cert_name" {
  description = "The name of the SSL certificate"
  type        = string
  default     = "lb-ssl-cert"
}

variable "static_backend_name" {
  description = "The name of the static content backend bucket"
  type        = string
  default     = "static-backend"
}

variable "cloud_run_neg_name" {
  description = "The name of the Cloud Run Network Endpoint Group"
  type        = string
  default     = "cloud-run-neg"
}

variable "cloud_run_backend_name" {
  description = "The name of the Cloud Run backend service"
  type        = string
  default     = "cloud-run-backend"
}

variable "url_map_name" {
  description = "The name of the URL map"
  type        = string
  default     = "lb-url-map"
}

variable "https_proxy_name" {
  description = "The name of the HTTPS proxy"
  type        = string
  default     = "lb-https-proxy"
}

variable "https_forwarding_rule_name" {
  description = "The name of the HTTPS forwarding rule"
  type        = string
  default     = "lb-https-forwarding-rule"
}

variable "http_forwarding_rule_name" {
  description = "The name of the HTTP forwarding rule"
  type        = string
  default     = "lb-http-forwarding-rule"
}
