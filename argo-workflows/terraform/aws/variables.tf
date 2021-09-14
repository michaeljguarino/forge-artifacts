variable "namespace" {
  type = string
  default = "argo-workflows"
}

variable "workflow_bucket" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "plural"
}

variable "kubeflow_serviceaccount" {
  type = string
  default = "argo-wrokflow"
}

variable "role_name" {
  type = string
  default = "argo-workflows"
}
