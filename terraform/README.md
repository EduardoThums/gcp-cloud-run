terraform init
gcloud auth application-default login


Cloud Run (with VPC interface) → Subnet 1 (10.0.0.0/24) → VPC → Cloud SQL (Private IP)


Cloud Run → VPC → Private DNS Zone → A Record → Cloud SQL Private IP
                                 → CNAME Record → A Record → Cloud SQL Private IP
