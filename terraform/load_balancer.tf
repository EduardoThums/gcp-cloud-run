resource "google_storage_bucket" "static_content" {
  name                        = var.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
  public_access_prevention = "enforced"
}

# resource "google_storage_bucket_iam_member" "static_content_public_read" {
#   bucket = google_storage_bucket.static_content.name
#   role   = "roles/storage.objectViewer"
#   member = "allUsers"
# }

resource "google_compute_global_address" "default" {
  name = var.lb_ip_name
}

# resource "google_compute_backend_bucket" "static_content" {
#   name        = var.static_backend_name
#   description = "Contains static content"
#   bucket_name = google_storage_bucket.static_content.name
#   enable_cdn  = true
  
#   cdn_policy {
#     cache_mode                   = "CACHE_ALL_STATIC"
#     client_ttl                   = 3600
#     default_ttl                  = 3600
#     max_ttl                      = 86400
#     negative_caching             = true
#     serve_while_stale            = 0
#     request_coalescing = true
#     # cache_key_policy {
#     #   include_host           = true
#     #   include_protocol       = true
#     #   include_query_string   = false
#     # }
#   }
  
#   compression_mode = "AUTOMATIC"
  
#   custom_response_headers = [
#     "X-Content-Type-Options: nosniff",
#     "X-Frame-Options: DENY",
#     "X-XSS-Protection: 1; mode=block",
#     "Strict-Transport-Security: max-age=63072000; includeSubDomains; preload",
#     "Referrer-Policy: strict-origin-when-cross-origin",
#     "Permissions-Policy: geolocation=(), microphone=(), camera=()"
#   ]
# }

resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = var.cloud_run_neg_name
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id

  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

# Create Network Endpoint Group for Cloud Function (2nd gen)
resource "google_compute_region_network_endpoint_group" "cloud_function_neg" {
  name                  = var.cloud_function_neg_name
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id

  cloud_function {
    function = google_cloudfunctions2_function.storage_auth_edge.name
  }
}


# Create backend service for Cloud Run
resource "google_compute_backend_service" "cloud_run_backend" {
  name                  = var.cloud_run_backend_name
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = false
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }
}

# Create backend service for Cloud Function
resource "google_compute_backend_service" "cloud_function_backend" {
  name                  = var.cloud_function_backend_name
  project               = var.project_id
  protocol              = "HTTPS"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = true
  compression_mode = "DISABLED"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  
  cdn_policy {
    cache_mode = "USE_ORIGIN_HEADERS"
    signed_url_cache_max_age_sec = 0

    cache_key_policy {
      include_host = true
      include_protocol = true
      include_query_string = false
    #   include_http_headers = 
    }
  }

  backend {
    group = google_compute_region_network_endpoint_group.cloud_function_neg.id
  }
}

# Create url map
resource "google_compute_url_map" "default" {
  name = var.url_map_name

  default_service = google_compute_backend_service.cloud_function_backend.id

  host_rule {
    hosts        = [var.domain_name]
    path_matcher = "path-matcher-1"
  }
  path_matcher {
    name            = "path-matcher-1"
    default_service = google_compute_backend_service.cloud_function_backend.id

    # Route API calls to Cloud Run
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.cloud_run_backend.id
    }

    # Route static bucket access (if needed for specific paths)
    # path_rule {
    #   paths   = ["/static/*"]
    #   service = google_compute_backend_bucket.static_content.id
    # }
  }

  depends_on = [ google_compute_backend_service.cloud_run_backend, google_compute_backend_service.cloud_function_backend ]
}


# # Create managed SSL certificate
resource "google_compute_managed_ssl_certificate" "lb_ssl_cert" {
  name    = var.ssl_cert_name
  project = var.project_id

  managed {
    domains = [var.domain_name]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create HTTP target proxy
resource "google_compute_target_https_proxy" "default" {
  name    = "https-proxy"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_ssl_cert.id]
}

# Create forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
