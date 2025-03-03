resource "aws_security_group" "this" {
  for_each = var.names

  name        = each.value
  description = "${each.value} VPC security group"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.tag_prefix}${each.value}-security-group"
  }
}
