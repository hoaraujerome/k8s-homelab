variable "name" {
  description = "Instance profile name"
  type        = string
  nullable    = false
}

variable "tag_prefix" {
  type    = string
  default = ""
}

variable "actions" {
  description = "List of IAM actions (e.g., ssm:GetParameter)"
  type        = set(string)
  nullable    = false
}

variable "resources" {
  description = "List of resource ARNs"
  type        = set(string)
  nullable    = false
}

