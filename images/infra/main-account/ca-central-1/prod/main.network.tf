locals {
  vpc_ipv4_cidr_block           = "10.50.0.0/16"
  packer_subnet_ipv4_cidr_block = "10.50.1.0/24"
}

module "vpc" {
  source = "../../../../../modules/infra/network-vpc"

  tag_prefix          = local.tag_prefix
  vpc_ipv4_cidr_block = local.vpc_ipv4_cidr_block
  subnets = {
    (local.packer_subnet_name) = {
      ipv4_cidr_block         = local.packer_subnet_ipv4_cidr_block
      map_public_ip_on_launch = true
    }
  }
}

module "internet-gateway" {
  source = "../../../../../modules/infra/network-internetgateway"

  vpc_id     = module.vpc.vpc_id
  tag_prefix = local.tag_prefix
}

module "internet-gateway-route-table" {
  source = "../../../../../modules/infra/network-routetable-all-traffic"

  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.packer_subnet_name}"]
  gateway_id   = module.internet-gateway.id
  gateway_type = "igw"
  tag_prefix   = local.tag_prefix
}

output "packer_vpc_id" {
  value = module.vpc.vpc_id
}

output "packer_subnet_id" {
  value = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.packer_subnet_name}"]
}
