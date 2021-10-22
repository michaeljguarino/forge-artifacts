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
variable "instance_types_small" {
  type = list(string)
  default = ["t3.large","t3a.large"]
  description = "instance type to use in small node group"
}

variable "instance_types_medium" {
  type = list(string)
  default = ["t3.xlarge","t3a.xlarge"]
  description = "instance type to use in medium node group"
}

variable "instance_types_large" {
  type = list(string)
  default = ["t3.2xlarge","t3a.2xlarge"]
  description = "instance type to use in gpu node group"
}

variable "instance_types_gpu_small" {
  type = list(string)
  default = ["g4dn.xlarge"]
  description = "instance type to use in gpu node group"
}
