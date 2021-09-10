variable "namespace" {
  type = string
  default = "nextcloud"
}

variable "nextcloud_bucket" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "plural"
}

variable "nextcloud_serviceaccount" {
  type = string
  default = "default-editor"
}

variable "role_name" {
  type = string
  default = "nextcloud"
}
