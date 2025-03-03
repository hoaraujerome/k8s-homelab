variable "subnet_id" {
  type     = string
  nullable = false
}

variable "security_group_ids" {
  type    = set(string)
  default = []
}

variable "key_pair_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
