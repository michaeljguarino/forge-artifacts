variable "namespace" {
  type = string
  default = "external-secrets"
}

variable "cluster_name" {
  type = string
}

variable "account_id" {
  type = string
  description = "the AWS account ID"
}

variable "region" {
  type = string
  description = "region of the cluster"
}

variable "role_name" {
  type = string
  description = "name of the role"
  default = "external-secrets"
}

variable "serviceaccount" {
  type = string
  description = "service account that can assume the role"
  default = "external-secrets"
}

variable "extra_policy_arns" {
  type = list(string)
  default = []
}

variable "secret_prefix" {
  type = string
  default = "*"
  description = "the prefix that should be used for the policy allowing access to secrets"
}
