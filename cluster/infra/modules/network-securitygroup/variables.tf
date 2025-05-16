variable "vpc_id" {
  type     = string
  nullable = false
}

variable "names" {
  type     = set(string)
  nullable = false

  validation {
    condition     = length(var.names) > 0
    error_message = "At least one name must be set"
  }
}

variable "tag_prefix" {
  type    = string
  default = ""
}
