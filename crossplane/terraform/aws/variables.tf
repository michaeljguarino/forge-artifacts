variable "cluster_name" {
  type = string
  default = "piazza"
}

variable "namespace" {
  type = string
  default = "crossplane"
}

variable "crossplane_serviceaccount" {
  type = string
  default = "crossplane"
}

variable "role_name" {
  type = string
  default = "crossplane"
}