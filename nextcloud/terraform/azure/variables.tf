variable "cluster_name" {
  type = string
  default = "plural"
}

variable "namespace" {
  type = string
  default = "nextcloud"
}

variable "nextcloud_bucket" {
  type = string
}

variable "minio_region" {
  description = "Default MinIO region"
  default     = "us-east-1"
}

variable "minio_server" {
  description = "Default MinIO host and port"
  default = "minio.minio:9000"
}

variable "minio_access_key" {
  description = "MinIO user"
  default = "minio"
}

variable "minio_secret_key" {
  description = "MinIO secret user"
  default = "minio123"
}
