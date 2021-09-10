variable "subnet_name" {
  type = string
  default = "plural-subnet"
}

variable "resource_group" {
  type = string
}


variable "address_space" {
  type = string
  default = "10.1.0.0/16"
}

variable "subnet_prefixes" {
  type = list(string)
  default = ["10.1.0.0/22"]
}

variable "name" {
  type = string
  default = "plural"
}

variable "os_disk_size" {
  type = number
  default = 50
}

variable "os_disk_type" {
  type = string
  default = "Ephemeral"
}

variable "private_cluster" {
  type = bool
  default = false
}

variable "min_nodes" {
  type = number
  default = 3
}

variable "max_nodes" {
  type = number
  default = 25
}

variable "dns_zone_name" {
  type = string
}

variable "namespace" {
  type = string
  default = "bootstrap"
}