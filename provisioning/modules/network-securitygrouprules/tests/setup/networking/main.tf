locals {
  vpc_ipv4_cidr_block = "10.1.0.0/16"
}

# Require Vpc Flow Logs For All Vpcs
# https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0178/
#trivy:ignore:AVD-AWS-0178
resource "aws_vpc" "test" {
  cidr_block           = local.vpc_ipv4_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tests-vpc"
  }
}

resource "aws_security_group" "test1" {
  description = "security group #1 for testing purposes"
  name        = "tests-sg-1"
  vpc_id      = aws_vpc.test.id
}

output "sg1_id" {
  value = aws_security_group.test1.id
}

resource "aws_security_group" "test2" {
  description = "security group #1 for testing purposes"
  name        = "tests-sg-2"
  vpc_id      = aws_vpc.test.id
}

output "sg2_id" {
  value = aws_security_group.test2.id
}
