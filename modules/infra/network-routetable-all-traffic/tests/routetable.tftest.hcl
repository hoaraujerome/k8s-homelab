run "setup_provider" {
  module {
    source = "../../../tests/setup/aws_provider"
  }
}

run "check_rt_for_unknown_gw" {
  variables {
    vpc_id       = "vpcid"
    subnet_id    = "subnetid"
    gateway_id   = "gwid"
    gateway_type = "foo"
  }

  command = plan

  expect_failures = [
    var.gateway_type,
  ]
}

run "check_rt_for_igw" {
  variables {
    vpc_id       = "vpcid"
    subnet_id    = "subnetid"
    gateway_id   = "gwid"
    gateway_type = "igw"
    tag_prefix   = "prefix-"
  }

  command = plan

  assert {
    condition     = aws_route_table.this.vpc_id == var.vpc_id
    error_message = "Invalid route table VPC id"
  }

  assert {
    condition     = anytrue([for route in aws_route_table.this.route : route.cidr_block == "0.0.0.0/0" && route.gateway_id == var.gateway_id])
    error_message = "Invalid route table route cidr block"
  }

  assert {
    condition     = aws_route_table.this.tags["Name"] == "prefix-route-table"
    error_message = "Invalid route table name tag"
  }

  assert {
    condition     = aws_route_table_association.this.subnet_id == var.subnet_id
    error_message = "Invalid route table assoication subnet id"
  }
}

run "check_rt_for_nat" {
  variables {
    vpc_id       = "vpcid"
    subnet_id    = "subnetid"
    gateway_id   = "gwid"
    gateway_type = "nat"
    tag_prefix   = "prefix-"
  }

  command = plan

  assert {
    condition     = anytrue([for route in aws_route_table.this.route : route.cidr_block == "0.0.0.0/0" && route.nat_gateway_id == var.gateway_id])
    error_message = "Invalid route table route cidr block"
  }
}

run "setup_networking" {
  module {
    source = "./tests/setup/networking"
  }
}

run "create_rt" {
  variables {
    vpc_id       = run.setup_networking.vpc_id
    subnet_id    = run.setup_networking.subnet_id
    gateway_id   = run.setup_networking.internet_gateway_id
    gateway_type = "igw"
    tag_prefix   = "prefix-"
  }

  command = apply

  assert {
    condition     = aws_route_table_association.this.route_table_id == aws_route_table.this.id
    error_message = "Invalid route table association route table id"
  }
}
