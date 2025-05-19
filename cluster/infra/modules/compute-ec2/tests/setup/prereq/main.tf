locals {
  vpc_ipv4_cidr_block    = "10.1.0.0/16"
  subnet_ipv4_cidr_block = "10.1.1.0/24"
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

resource "aws_subnet" "test" {
  vpc_id     = aws_vpc.test.id
  cidr_block = local.subnet_ipv4_cidr_block

  tags = {
    Name = "tests-subnet"
  }
}

output "subnet_id" {
  value = aws_subnet.test.id
}

resource "aws_security_group" "test1" {
  description = "security group #1 for testing purposes"
  name        = "tests-sg-1"
  vpc_id      = aws_vpc.test.id
}

output "sg1_id" {
  value = aws_security_group.test1.id
}

data "aws_iam_policy_document" "test" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "test" {
  name               = "tests-instance-profile"
  assume_role_policy = data.aws_iam_policy_document.test.json
}

resource "aws_iam_instance_profile" "test" {
  name = "tests-instance-profile"
  role = aws_iam_role.test.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.test.name
}
