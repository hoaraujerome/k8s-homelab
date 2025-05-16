run "setup_provider" {
  module {
    source = "../../../../modules/tests/setup/aws_provider"
  }
}

run "check_ec2_instance_connect_endpoint" {
  variables {
    subnet_id          = "id"
    tag_prefix         = "prefix-"
    security_group_ids = ["sg1", "sg2"]
  }

  command = plan

  assert {
    condition     = aws_ec2_instance_connect_endpoint.this.subnet_id == var.subnet_id
    error_message = "Invalid EC2 instance connect endpoint subnet ID"
  }

  assert {
    condition     = aws_ec2_instance_connect_endpoint.this.security_group_ids == var.security_group_ids
    error_message = "Invalid EC2 instance connect endpoint SG ids"
  }

  assert {
    condition     = aws_ec2_instance_connect_endpoint.this.tags["Name"] == "prefix-ec2-instance-connect-endpoint"
    error_message = "Invalid EC2 instance connect endpoint tag name"
  }
}

run "setup_networking" {
  module {
    source = "./tests/setup/networking"
  }
}

run "create_ec2_instance_connect_endpoint" {
  variables {
    subnet_id          = run.setup_networking.subnet_id
    security_group_ids = [run.setup_networking.sg1_id]
  }

  command = apply
}
