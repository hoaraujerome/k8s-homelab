variable "security_group_id" {
  type     = string
  nullable = false
}

variable "rules" {
  type = map(object({
    description                  = optional(string)
    direction                    = string
    from_port                    = number
    to_port                      = number
    ip_protocol                  = string
    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))

  validation {
    condition = alltrue([
      for rule in values(var.rules) : rule.direction == "inbound" || rule.direction == "outbound"
    ])
    error_message = "Each rule's direction must be either 'inbound' or 'outbound'."
  }

  validation {
    condition = alltrue([
      for rule in values(var.rules) : rule.cidr_ipv4 != null || rule.referenced_security_group_id != null
    ])
    error_message = "Each rule must have either 'cidr_ipv4' or 'referenced_security_group_id' specified."
  }

  validation {
    condition = alltrue([
      for rule in values(var.rules) : !(rule.cidr_ipv4 != null && rule.referenced_security_group_id != null)
    ])
    error_message = "Each rule must specify either 'cidr_ipv4' or 'referenced_security_group_id', but not both."
  }
}


variable "tag_prefix" {
  type    = string
  default = ""
}
