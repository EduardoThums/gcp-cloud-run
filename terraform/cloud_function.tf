resource "google_project_service" "cloud_function_api" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# resource "google_project_service" "cloud_run_api" {
#   project = var.project_id
#   service = "run.googleapis.com"

#   disable_dependent_services = true
#   disable_on_destroy         = false
# }

resource "google_project_service" "cloud_build_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "artifact_registry_api" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Grant Artifact Registry permissions to the function service account
resource "google_project_iam_member" "function_artifact_registry_list" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}


# Cloud Function for authenticated storage access
resource "google_storage_bucket" "function_source" {
  name                        = "${var.project_id}-function-source"
  location                    = var.region
  uniform_bucket_level_access = true
  
  # Auto-delete old versions
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Zip the function source code
data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "${path.root}/../edge-function"
  output_path = "${path.root}/edge-function.zip"
  excludes    = ["node_modules", ".git", "*.md", "env.example"]
}

# Upload function source to bucket
resource "google_storage_bucket_object" "function_source" {
  name   = "edge-function-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.function_source.output_path
}

# Service account for the Cloud Function
resource "google_service_account" "function_sa" {
  account_id   = "storage-auth-function"
  display_name = "Storage Authentication Function Service Account"
  description  = "Service account for the storage authentication edge function"
}

# Grant the function service account access to the storage bucket
resource "google_storage_bucket_iam_member" "function_storage_access" {
  bucket = google_storage_bucket.static_content.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.function_sa.email}"
}

# Deploy the 2nd Generation Cloud Function
resource "google_cloudfunctions2_function" "storage_auth_edge" {
  name        = "storage-auth-edge"
  location    = var.region
  description = "2nd gen edge function for authenticated access to Cloud Storage"

  build_config {
    runtime     = "nodejs22"
    entry_point = "storageAuth"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count    = 10
    min_instance_count    = 0
    available_memory      = "256M"
    timeout_seconds       = 30
    service_account_email = google_service_account.function_sa.email
    
    environment_variables = {
      STORAGE_BUCKET_NAME  = var.bucket_name
      AUTH_USERNAME        = var.edge_function_username
      AUTH_PASSWORD        = var.edge_function_password
      GOOGLE_CLOUD_PROJECT = var.project_id
    }

    # Ingress settings
    ingress_settings               = "ALLOW_INTERNAL_AND_GCLB"
    all_traffic_on_latest_revision = true
  }

  depends_on = [
    google_project_service.cloud_function_api,
    google_project_service.cloud_run_api,
    google_project_service.cloud_build_api,
    google_project_service.artifact_registry_api,
    google_storage_bucket_object.function_source,
    google_service_account.function_sa
  ]
}

# IAM policy to allow unauthenticated invocation for 2nd gen function
resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloudfunctions2_function.storage_auth_edge.location
  service  = google_cloudfunctions2_function.storage_auth_edge.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}