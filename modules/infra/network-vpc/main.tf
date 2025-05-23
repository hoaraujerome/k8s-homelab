# Require Vpc Flow Logs For All Vpcs
# https://avd.aquasec.com/misconfig/aws/ec2/avd-aws-0178/
#trivy:ignore:AVD-AWS-0178
resource "aws_vpc" "this" {
  cidr_block = var.vpc_ipv4_cidr_block
  # Instances in the VPC can use Amazon-provided DNS server
  enable_dns_support = true
  # Instances in the VPC will be assigned public DNS hostnames
  # if they have public IP addresses
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tag_prefix}vpc"
  }
}

# Subnet associates public IP address
# https://avd.aquasec.com/misconfig/aws-vpc-no-public-ingress-sgr
#trivy:ignore:AVD-AWS-0164
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.ipv4_cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = "${var.tag_prefix}${each.key}"
  }
}
