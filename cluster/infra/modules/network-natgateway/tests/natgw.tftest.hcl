run "setup_provider" {
  module {
    source = "../../../../modules/tests/setup/aws_provider"
  }
}

run "check_natgw" {
  variables {
    tag_prefix = "prefix-"
    subnet_id  = "subnetid"
  }

  command = plan

  assert {
    condition     = aws_eip.this.domain == "vpc"
    error_message = "Invalid EIP domain"
  }

  assert {
    condition     = aws_eip.this.tags["Name"] == "prefix-eip"
    error_message = "Invalid EIP name tag"
  }

  assert {
    condition     = aws_nat_gateway.this.subnet_id == var.subnet_id
    error_message = "Invalid NAT gateway subnet id"
  }

  assert {
    condition     = aws_nat_gateway.this.connectivity_type == "public"
    error_message = "Invalid NAT gateway connectivity type"
  }

  assert {
    condition     = aws_nat_gateway.this.tags["Name"] == "prefix-nat-gateway"
    error_message = "Invalid NAT gateway name tag"
  }
}

run "setup_networking" {
  module {
    source = "./tests/setup/networking"
  }
}

run "create_natgw" {
  variables {
    tag_prefix = "prefix-"
    subnet_id  = run.setup_networking.subnet_id
  }

  command = apply

  assert {
    condition     = aws_nat_gateway.this.allocation_id == aws_eip.this.id
    error_message = "Invalid NAT allocation ID"
  }

  assert {
    condition     = output.id == aws_nat_gateway.this.id
    error_message = "Invalid ouput id"
  }
}
