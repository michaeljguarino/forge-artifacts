# output "credentials_json" {
#   description = "Credentials JSON that allows access to the MySQL backup GCS bucket."
#   value       = google_service_account_key.mysql_key.private_key
# }

output "gcp_sa_name" {
  description = "Name of the GCP service account that has access to the MySQL backup GCS bucket."
  value       = module.mysql-workload-identity.gcp_service_account_name
}
