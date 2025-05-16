run "setup_provider" {
  module {
    source = "../../../../modules/tests/setup/aws_provider"
  }
}

run "check_rules_for_unknown_direction" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo" = {
        direction   = "unknown"
        from_port   = "123"
        to_port     = "123"
        ip_protocol = "tcp"
        cidr_ipv4   = "1.2.3.4/32"
      }
    }
  }

  command = plan

  expect_failures = [
    var.rules,
  ]
}

run "check_rules_for_missing_target" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo" = {
        direction   = "inbound"
        from_port   = "123"
        to_port     = "123"
        ip_protocol = "tcp"
      }
    }
  }

  command = plan

  expect_failures = [
    var.rules,
  ]
}

run "check_rules_for_two_targets" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo" = {
        direction                    = "inbound"
        from_port                    = "123"
        to_port                      = "123"
        ip_protocol                  = "tcp"
        cidr_ipv4                    = "1.2.3.4/32"
        referenced_security_group_id = "refsgid"
      }
    }
  }

  command = plan

  expect_failures = [
    var.rules,
  ]
}

run "check_rules_with_no_rules" {
  variables {
    security_group_id = "sgid"
    rules             = {}
  }

  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress) == 0
    error_message = "Invalid security group ingress rules"
  }

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.egress) == 0
    error_message = "Invalid security group egress rules"
  }
}

run "check_rules_with_one_ingress_rule_with_cidr_as_target" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo" = {
        description = "description"
        direction   = "inbound"
        from_port   = "123"
        to_port     = "123"
        ip_protocol = "tcp"
        cidr_ipv4   = "1.2.3.4/32"
      }
    }
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress) == 1
    error_message = "Invalid security group ingress rules"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].description == var.rules["foo"].description
    error_message = "Invalid security group ingress rule description"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].from_port == var.rules["foo"].from_port
    error_message = "Invalid security group ingress rule from port"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].to_port == var.rules["foo"].to_port
    error_message = "Invalid security group ingress rule to port"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].ip_protocol == var.rules["foo"].ip_protocol
    error_message = "Invalid security group ingress rule IP protocol"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].cidr_ipv4 == var.rules["foo"].cidr_ipv4
    error_message = "Invalid security group ingress rule ip"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].security_group_id == var.security_group_id
    error_message = "Invalid security group ingress rule ip"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].tags["Name"] == "prefix-foo"
    error_message = "Invalid security group ingress rule name tag"
  }
}

run "check_rules_with_one_ingress_rule_with_sg_as_target" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo" = {
        direction                    = "inbound"
        from_port                    = "123"
        to_port                      = "123"
        ip_protocol                  = "tcp"
        referenced_security_group_id = "refsgid"
      }
    }
  }

  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress) == 1
    error_message = "Invalid security group ingress rules"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress["foo"].referenced_security_group_id == var.rules["foo"].referenced_security_group_id
    error_message = "Invalid security group ingress rule ref sg id"
  }
}

run "check_rules_with_three_ingress_rules" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo1" = {
        direction   = "inbound"
        from_port   = "1"
        to_port     = "1"
        ip_protocol = "tcp"
        cidr_ipv4   = "1.2.3.4/32"
      },
      "foo2" = {
        direction   = "inbound"
        from_port   = "2"
        to_port     = "2"
        ip_protocol = "tcp"
        cidr_ipv4   = "2.2.3.4/32"
      },
      "foo3" = {
        direction   = "inbound"
        from_port   = "3"
        to_port     = "3"
        ip_protocol = "tcp"
        cidr_ipv4   = "3.2.3.4/32"
      }
    }
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress) == 3
    error_message = "Invalid security group ingress rules"
  }
}

run "check_rules_with_one_egress_rule_with_cidr_as_target" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo" = {
        description = "description"
        direction   = "outbound"
        from_port   = "123"
        to_port     = "123"
        ip_protocol = "tcp"
        cidr_ipv4   = "1.2.3.4/32"
      }
    }
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.egress) == 1
    error_message = "Invalid security group egress rules"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].description == var.rules["foo"].description
    error_message = "Invalid security group egress rule description"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].from_port == var.rules["foo"].from_port
    error_message = "Invalid security group egress rule from port"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].to_port == var.rules["foo"].to_port
    error_message = "Invalid security group egress rule to port"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].ip_protocol == var.rules["foo"].ip_protocol
    error_message = "Invalid security group egress rule IP protocol"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].cidr_ipv4 == var.rules["foo"].cidr_ipv4
    error_message = "Invalid security group egress rule ip"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].security_group_id == var.security_group_id
    error_message = "Invalid security group egress rule ip"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].tags["Name"] == "prefix-foo"
    error_message = "Invalid security group egress rule name tag"
  }
}

run "check_rules_with_one_egress_rule_with_sg_as_target" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo" = {
        direction                    = "outbound"
        from_port                    = "123"
        to_port                      = "123"
        ip_protocol                  = "tcp"
        referenced_security_group_id = "refsgid"
      }
    }
  }

  command = plan

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.egress) == 1
    error_message = "Invalid security group egress rules"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.egress["foo"].referenced_security_group_id == var.rules["foo"].referenced_security_group_id
    error_message = "Invalid security group egress rule ref sg id"
  }
}

run "check_rules_with_three_egress_rules" {
  variables {
    security_group_id = "sgid"
    rules = {
      "foo1" = {
        direction   = "outbound"
        from_port   = "1"
        to_port     = "1"
        ip_protocol = "tcp"
        cidr_ipv4   = "1.2.3.4/32"
      },
      "foo2" = {
        direction   = "outbound"
        from_port   = "2"
        to_port     = "2"
        ip_protocol = "tcp"
        cidr_ipv4   = "2.2.3.4/32"
      },
      "foo3" = {
        direction   = "outbound"
        from_port   = "3"
        to_port     = "3"
        ip_protocol = "tcp"
        cidr_ipv4   = "3.2.3.4/32"
      }
    }
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = length(aws_vpc_security_group_egress_rule.egress) == 3
    error_message = "Invalid security group egress rules"
  }
}

run "setup_networking" {
  module {
    source = "./tests/setup/networking"
  }
}

run "create_rules" {
  variables {
    security_group_id = run.setup_networking.sg1_id
    rules = {
      "foo1" = {
        direction   = "inbound"
        from_port   = "123"
        to_port     = "123"
        ip_protocol = "tcp"
        cidr_ipv4   = "1.2.3.4/32"
      },
      "foo2" = {
        direction                    = "outbound"
        from_port                    = "123"
        to_port                      = "123"
        ip_protocol                  = "tcp"
        referenced_security_group_id = run.setup_networking.sg2_id
      }
    }
  }

  command = apply
}
