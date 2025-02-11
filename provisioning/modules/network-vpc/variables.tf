variable "vpc_ipv4_cidr_block" {
  type     = string
  nullable = false
}

variable "tag_prefix" {
  type    = string
  default = ""
}

variable "subnets" {
  type = map(object({
    ipv4_cidr_block = string
  }))
  default = {}
}
