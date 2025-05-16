run "setup_provider" {
  module {
    source = "../../tests/setup/aws_provider"
  }
}

run "check_igw" {
  variables {
    vpc_id     = "vpcid"
    tag_prefix = "prefix-"
  }

  command = plan

  assert {
    condition     = aws_internet_gateway.this.vpc_id == var.vpc_id
    error_message = "Invalid internet gateway VPC id"
  }

  assert {
    condition     = aws_internet_gateway.this.tags["Name"] == "prefix-internet-gateway"
    error_message = "Invalid internet gateway name tag"
  }
}

run "setup_networking" {
  module {
    source = "./tests/setup/networking"
  }
}

run "create_igw" {
  variables {
    vpc_id     = run.setup_networking.vpc_id
    tag_prefix = "prefix-"
  }

  command = apply

  assert {
    condition     = output.id == aws_internet_gateway.this.id
    error_message = "Invalid ouput id"
  }
}
