run "setup_provider" {
  module {
    source = "../../../tests/setup/aws_provider"
  }
}

run "check_vpc_with_no_subnet" {
  variables {
    vpc_ipv4_cidr_block = "1.1.1.0/28"
    tag_prefix          = "prefix-"
  }

  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == var.vpc_ipv4_cidr_block
    error_message = "Invalid VPC CIDR block"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "Invalid VPC enable DNS support"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "Invalid VPC enable DNS hostnames"
  }

  assert {
    condition     = aws_vpc.this.tags["Name"] == format("%svpc", var.tag_prefix)
    error_message = "Invalid VPC tag name"
  }

  assert {
    condition     = length(aws_subnet.this) == 0
    error_message = "Invalid subnet"
  }
}

run "check_vpc_with_one_subnet" {
  variables {
    vpc_ipv4_cidr_block = "1.1.1.0/28"
    subnets = {
      "bastion" = {
        ipv4_cidr_block         = "10.1.1.0/24"
        map_public_ip_on_launch = true
      }
    }
    tag_prefix = "px-"
  }

  command = plan

  assert {
    condition     = length(aws_subnet.this) == 1
    error_message = "Invalid subnet"
  }

  assert {
    condition     = aws_subnet.this["bastion"].cidr_block == var.subnets.bastion.ipv4_cidr_block
    error_message = "Invalid bastion subnet CIDR block"
  }

  assert {
    condition     = aws_subnet.this["bastion"].map_public_ip_on_launch == var.subnets.bastion.map_public_ip_on_launch
    error_message = "Invalid bastion map public IP on launch"
  }

  assert {
    condition     = aws_subnet.this["bastion"].tags["Name"] == format("%sbastion", var.tag_prefix)
    error_message = "Invalid bastion subnet tag name"
  }
}

run "check_vpc_with_three_subnets" {
  variables {
    vpc_ipv4_cidr_block = "1.1.1.0/28"
    subnets = {
      "bastion" = {
        ipv4_cidr_block         = "10.1.1.0/24"
        map_public_ip_on_launch = true
      }
      "transit" = {
        ipv4_cidr_block         = "10.1.2.0/24"
        map_public_ip_on_launch = false
      }
      "foo" = {
        ipv4_cidr_block         = "10.1.3.0/24"
        map_public_ip_on_launch = true
      }
    }
    tag_prefix = "px-"
  }

  command = plan

  assert {
    condition     = length(aws_subnet.this) == 3
    error_message = "Invalid subnet"
  }

  assert {
    condition     = aws_subnet.this["bastion"].cidr_block == var.subnets.bastion.ipv4_cidr_block
    error_message = "Invalid bastion subnet CIDR block"
  }

  assert {
    condition     = aws_subnet.this["bastion"].map_public_ip_on_launch == var.subnets.bastion.map_public_ip_on_launch
    error_message = "Invalid bastion map public IP on launch"
  }

  assert {
    condition     = aws_subnet.this["bastion"].tags["Name"] == format("%sbastion", var.tag_prefix)
    error_message = "Invalid bastion subnet tag name"
  }

  assert {
    condition     = aws_subnet.this["transit"].cidr_block == var.subnets.transit.ipv4_cidr_block
    error_message = "Invalid transit subnet CIDR block"
  }

  assert {
    condition     = aws_subnet.this["transit"].map_public_ip_on_launch == var.subnets.transit.map_public_ip_on_launch
    error_message = "Invalid transit map public IP on launch"
  }

  assert {
    condition     = aws_subnet.this["transit"].tags["Name"] == format("%stransit", var.tag_prefix)
    error_message = "Invalid transit subnet tag name"
  }

  assert {
    condition     = aws_subnet.this["foo"].cidr_block == var.subnets.foo.ipv4_cidr_block
    error_message = "Invalid foo subnet CIDR block"
  }

  assert {
    condition     = aws_subnet.this["foo"].map_public_ip_on_launch == var.subnets.foo.map_public_ip_on_launch
    error_message = "Invalid foo map public IP on launch"
  }

  assert {
    condition     = aws_subnet.this["foo"].tags["Name"] == format("%sfoo", var.tag_prefix)
    error_message = "Invalid foo subnet tag name"
  }
}

run "create_vpc_with_no_subnet" {
  variables {
    vpc_ipv4_cidr_block = "10.1.0.0/16"
  }

  command = apply

  assert {
    condition     = output.vpc_id == aws_vpc.this.id
    error_message = "Invalid ouput VPC id"
  }

  assert {
    condition     = output.subnet_ids_by_name == {}
    error_message = "Invalid ouput subnets ids by name"
  }
}

run "create_vpc_with_three_subnets" {
  variables {
    vpc_ipv4_cidr_block = "10.1.0.0/16"
    subnets = {
      "bastion" = {
        ipv4_cidr_block         = "10.1.1.0/24"
        map_public_ip_on_launch = true
      }
      "transit" = {
        ipv4_cidr_block         = "10.1.2.0/24"
        map_public_ip_on_launch = false
      }
      "foo" = {
        ipv4_cidr_block         = "10.1.3.0/24"
        map_public_ip_on_launch = true
      }
    }
  }

  command = apply

  assert {
    condition     = aws_subnet.this["bastion"].vpc_id == aws_vpc.this.id
    error_message = "Invalid bastion subnet VPC id"
  }

  assert {
    condition     = output.subnet_ids_by_name["bastion"] == aws_subnet.this["bastion"].id
    error_message = "Invalid ouput bastion subnet id"
  }

  assert {
    condition     = output.subnet_ids_by_name["transit"] == aws_subnet.this["transit"].id
    error_message = "Invalid ouput transit subnet id"
  }
  assert {
    condition     = output.subnet_ids_by_name["foo"] == aws_subnet.this["foo"].id
    error_message = "Invalid ouput foo subnet id"
  }
}
