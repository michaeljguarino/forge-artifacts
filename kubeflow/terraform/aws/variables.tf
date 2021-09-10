variable "namespace" {
  type = string
  default = "kubeflow"
}

variable "pipelines_bucket" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "plural"
}

variable "kubeflow_serviceaccount" {
  type = string
  default = "default-editor"
}

variable "role_name" {
  type = string
  default = "kubeflow"
}