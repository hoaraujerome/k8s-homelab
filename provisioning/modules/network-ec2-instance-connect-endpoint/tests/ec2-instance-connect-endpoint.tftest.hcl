run "setup_provider" {
  module {
    source = "../../tests/setup/aws_provider"
  }
}

run "check_ec2_instance_connect_endpoint" {
  variables {
    subnet_id  = "id"
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = aws_ec2_instance_connect_endpoint.this.subnet_id == var.subnet_id
    error_message = "Invalid EC2 instance connect endpoint subnet ID"
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
    subnet_id = run.setup_networking.subnet_id
  }

  command = apply

  # assert {
  #   condition     = aws_instance.this.associate_public_ip_address == var.associate_public_ip_address
  #   error_message = "Invalid instance associate public IP address"
  # }

  # assert {
  #   condition     = output.instance_public_dns != null
  #   error_message = "Invalid instance public dns"
  # }

  # assert {
  #   condition     = output.instance_private_dns != null
  #   error_message = "Invalid instance private dns"
  # }
}
