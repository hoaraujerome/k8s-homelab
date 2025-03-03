resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = {
    for idx, rule in var.rules : idx => rule if rule.direction == "inbound"
  }

  description                  = each.value.description
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.cidr_ipv4 != null ? each.value.cidr_ipv4 : null
  referenced_security_group_id = each.value.referenced_security_group_id != null ? each.value.referenced_security_group_id : null
  security_group_id            = var.security_group_id
  tags = {
    Name = "${var.tag_prefix}${each.key}"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = {
    for idx, rule in var.rules : idx => rule if rule.direction == "outbound"
  }

  description                  = each.value.description
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.cidr_ipv4 != null ? each.value.cidr_ipv4 : null
  referenced_security_group_id = each.value.referenced_security_group_id != null ? each.value.referenced_security_group_id : null
  security_group_id            = var.security_group_id
  tags = {
    Name = "${var.tag_prefix}${each.key}"
  }
}
