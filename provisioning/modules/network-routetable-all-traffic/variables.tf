variable "vpc_id" {
  type     = string
  nullable = false
}

variable "subnet_id" {
  type     = string
  nullable = false
}

variable "gateway_id" {
  type     = string
  nullable = false
}

variable "tag_prefix" {
  type    = string
  default = ""
}

variable "gateway_type" {
  type = string

  validation {
    condition     = contains(["igw", "nat"], var.gateway_type)
    error_message = "The gateway_type variable must be either 'igw' or 'nat'."
  }
}
