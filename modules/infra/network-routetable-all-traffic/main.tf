locals {
  all_ipv4_addresses = "0.0.0.0/0"
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = local.all_ipv4_addresses
    gateway_id     = var.gateway_type == "igw" ? var.gateway_id : null
    nat_gateway_id = var.gateway_type == "nat" ? var.gateway_id : null
  }

  tags = {
    Name = "${var.tag_prefix}route-table"
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.this.id
}
