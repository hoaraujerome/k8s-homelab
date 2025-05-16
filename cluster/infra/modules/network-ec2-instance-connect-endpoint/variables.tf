variable "subnet_id" {
  type     = string
  nullable = false
}

variable "security_group_ids" {
  type    = set(string)
  default = []
}

variable "tag_prefix" {
  type    = string
  default = ""
}
