resource "aws_eip" "this" {
  domain = "vpc"

  tags = {
    Name = "${var.tag_prefix}eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = var.subnet_id

  connectivity_type = "public"
  tags = {
    Name = "${var.tag_prefix}nat-gateway"
  }
}
