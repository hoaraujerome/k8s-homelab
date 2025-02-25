locals {
  vpc_ipv4_cidr_block                = "10.0.0.0/16"
  k8s_cluster_subnet_ipv4_cidr_block = "10.0.1.0/24"
}

module "vpc" {
  source = "../../../modules/network-vpc"

  tag_prefix          = local.tag_prefix
  vpc_ipv4_cidr_block = local.vpc_ipv4_cidr_block
  subnets = {
    (local.k8s_cluster_subnet_name) = {
      ipv4_cidr_block = local.k8s_cluster_subnet_ipv4_cidr_block
    }
  }
}

module "ec2-instance-connect-endpoint" {
  source = "../../../modules/network-ec2-instance-connect-endpoint"

  subnet_id = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.k8s_cluster_subnet_name}"]
}

