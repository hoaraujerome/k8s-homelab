run "setup_provider" {
  module {
    source = "../../tests/setup/aws_provider"
  }
}

run "check_no_security_group_name" {
  variables {
    vpc_id = "vpcid"
    names  = []
  }

  command = plan

  expect_failures = [
    var.names,
  ]
}

run "check_one_security_group" {
  variables {
    vpc_id     = "vpcid"
    names      = ["test"]
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = aws_security_group.this[tolist(var.names)[0]].name == tolist(var.names)[0]
    error_message = "Invalid security group name"
  }

  assert {
    condition     = aws_security_group.this[tolist(var.names)[0]].description == "${tolist(var.names)[0]} VPC security group"
    error_message = "Invalid security group description"
  }

  assert {
    condition     = aws_security_group.this[tolist(var.names)[0]].vpc_id == var.vpc_id
    error_message = "Invalid security group VPC id"
  }

  assert {
    condition     = aws_security_group.this[tolist(var.names)[0]].tags["Name"] == "prefix-${tolist(var.names)[0]}-security-group"
    error_message = "Invalid security group name tag"
  }
}

run "check_three_security_groups" {
  variables {
    vpc_id     = "vpcid"
    names      = ["test1", "test2", "test3"]
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = length(aws_security_group.this) == 3
    error_message = "Invalid security groups"
  }
}

run "setup_networking" {
  module {
    source = "./tests/setup/networking"
  }
}

run "create_two_security_groups" {
  variables {
    vpc_id     = run.setup_networking.vpc_id
    names      = ["test1", "test2"]
    tag_prefix = "prefix-"
  }

  command = apply

  assert {
    condition     = output.security_group_id[tolist(var.names)[0]] == aws_security_group.this[tolist(var.names)[0]].id
    error_message = "Invalid first ouput security group id"
  }

  assert {
    condition     = output.security_group_id[tolist(var.names)[1]] == aws_security_group.this[tolist(var.names)[1]].id
    error_message = "Invalid second ouput security group id"
  }
}
