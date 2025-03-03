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

output "vpc_id" {
  value = aws_vpc.test.id
}
