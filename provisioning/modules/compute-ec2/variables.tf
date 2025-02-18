variable "subnet_id" {
  type     = string
  nullable = false
}

# variable "security_group_ids" {
#   type    = list(string)
#   default = []
# }

variable "key_pair_name" {
  type    = string
  default = ""
}

# variable "associate_public_ip_address" {
#   type = bool
# }

variable "tags" {
  type    = map(string)
  default = {}
}
