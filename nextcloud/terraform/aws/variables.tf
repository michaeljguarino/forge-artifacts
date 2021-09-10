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
  default = "nextcloud-serviceaccount"
}

variable "role_name" {
  type = string
  default = "nextcloud"
}
