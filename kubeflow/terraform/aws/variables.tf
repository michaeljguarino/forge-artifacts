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
  default = "kubeflow-operator"
}

variable "role_name" {
  type = string
  default = "kubeflow"
}