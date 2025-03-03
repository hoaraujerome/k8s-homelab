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

module "ec2-instance-connect-endpoint-security-groups" {
  source = "../../../modules/network-securitygroup"

  vpc_id     = module.vpc.vpc_id
  names      = [local.ec2_instance_connect_endpoint_component]
  tag_prefix = local.tag_prefix
}

module "ec2-instance-connect-endpoint-security-group-rules" {
  source = "../../../modules/network-securitygrouprules"

  security_group_id = module.ec2-instance-connect-endpoint-security-groups.security_group_id[local.ec2_instance_connect_endpoint_component]
  rules = {
    "ssh-outbound-traffic" = {
      description                  = "Allows outbound SSH traffic to all instances associated with the instance security group"
      direction                    = "outbound"
      from_port                    = local.ssh_port
      to_port                      = local.ssh_port
      ip_protocol                  = local.tcp_protocol
      referenced_security_group_id = module.k8s-cluster-ec2-control-plane-security-groups.security_group_id[local.k8s_control_plane_component]
    }
  }
  tag_prefix = local.tag_prefix
}

module "ec2-instance-connect-endpoint" {
  source = "../../../modules/network-ec2-instance-connect-endpoint"

  subnet_id          = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.k8s_cluster_subnet_name}"]
  security_group_ids = [module.ec2-instance-connect-endpoint-security-groups.security_group_id[local.ec2_instance_connect_endpoint_component]]
  tag_prefix         = local.tag_prefix
}

