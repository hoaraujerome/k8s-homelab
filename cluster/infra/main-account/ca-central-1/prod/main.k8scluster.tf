locals {
  anywhere_ip_v4 = "0.0.0.0/0"
  http_port      = 80
  https_port     = 443
  k8s_api_port   = 6443
}

module "k8s-cluster-ssh-public-key" {
  source = "../../../modules/compute-sshpublickey"

  public_key_path = var.ssh_public_key_path
  tag_prefix      = local.tag_prefix
}

module "k8s-cluster-security-groups" {
  source = "../../../modules/network-securitygroup"

  vpc_id = module.vpc.vpc_id
  names = [
    local.k8s_control_plane_component,
    local.k8s_worker_node_component
  ]
  tag_prefix = local.tag_prefix
}

module "k8s-cluster-ec2-control-plane-security-group-rules" {
  source = "../../../modules/network-securitygrouprules"

  security_group_id = module.k8s-cluster-security-groups.security_group_id[local.k8s_control_plane_component]
  rules = {
    "ssh-inbound-traffic" = {
      description                  = "Allows inbound SSH traffic from the resources associated with the endpoint security group"
      direction                    = "inbound"
      from_port                    = local.ssh_port
      to_port                      = local.ssh_port
      ip_protocol                  = local.tcp_protocol
      referenced_security_group_id = module.ec2-instance-connect-endpoint-security-groups.security_group_id[local.ec2_instance_connect_endpoint_component]
    }
    "http-outbound-traffic" = {
      description = "Allow HTTP outbound traffic"
      direction   = "outbound"
      from_port   = local.http_port
      to_port     = local.http_port
      ip_protocol = local.tcp_protocol
      cidr_ipv4   = local.anywhere_ip_v4
    }
    "https-outbound-traffic" = {
      description = "Allow HTTPS outbound traffic"
      direction   = "outbound"
      from_port   = local.https_port
      to_port     = local.https_port
      ip_protocol = local.tcp_protocol
      cidr_ipv4   = local.anywhere_ip_v4
    }
    "k8s-api-inbound-traffic" = {
      description                  = "Allow K8S API inbound traffic from worker nodes"
      direction                    = "inbound"
      from_port                    = local.k8s_api_port
      to_port                      = local.k8s_api_port
      ip_protocol                  = local.tcp_protocol
      referenced_security_group_id = module.k8s-cluster-security-groups.security_group_id[local.k8s_worker_node_component]
    }
  }
  tag_prefix = local.tag_prefix
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "k8s-cluster-ec2-control-plane-instance-profile" {
  source = "../../../modules/identity-iam-instance-profile"

  name       = local.k8s_control_plane_component
  tag_prefix = local.tag_prefix
  actions = [
    "ssm:PutParameter"
  ]
  resources = [
    "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/k8s-homelab/*"
  ]
}

module "k8s-cluster-ec2-control-plane" {
  source = "../../../modules/compute-ec2"

  subnet_id            = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.k8s_cluster_subnet_name}"]
  security_group_ids   = [module.k8s-cluster-security-groups.security_group_id[local.k8s_control_plane_component]]
  key_pair_name        = module.k8s-cluster-ssh-public-key.key_pair_name
  iam_instance_profile = module.k8s-cluster-ec2-control-plane-instance-profile.name
  tags = {
    Name = "${local.tag_prefix}${local.k8s_control_plane_component}"
    Role = local.k8s_control_plane_component
  }
}

# module "k8s-cluster-ec2-worker-node-security-group-rules" {
#   source = "../../../modules/network-securitygrouprules"
# 
#   security_group_id = module.k8s-cluster-security-groups.security_group_id[local.k8s_worker_node_component]
#   rules = {
#     "ssh-inbound-traffic" = {
#       description                  = "Allows inbound SSH traffic from the resources associated with the endpoint security group"
#       direction                    = "inbound"
#       from_port                    = local.ssh_port
#       to_port                      = local.ssh_port
#       ip_protocol                  = local.tcp_protocol
#       referenced_security_group_id = module.ec2-instance-connect-endpoint-security-groups.security_group_id[local.ec2_instance_connect_endpoint_component]
#     }
#     "http-outbound-traffic" = {
#       description = "Allow HTTP outbound traffic"
#       direction   = "outbound"
#       from_port   = local.http_port
#       to_port     = local.http_port
#       ip_protocol = local.tcp_protocol
#       cidr_ipv4   = local.anywhere_ip_v4
#     }
#     "https-outbound-traffic" = {
#       description = "Allow HTTPS outbound traffic"
#       direction   = "outbound"
#       from_port   = local.https_port
#       to_port     = local.https_port
#       ip_protocol = local.tcp_protocol
#       cidr_ipv4   = local.anywhere_ip_v4
#     }
#     "k8s-api-outbound-traffic" = {
#       description                  = "Allow K8S API outbound traffic"
#       direction                    = "outbound"
#       from_port                    = local.k8s_api_port
#       to_port                      = local.k8s_api_port
#       ip_protocol                  = local.tcp_protocol
#       referenced_security_group_id = module.k8s-cluster-security-groups.security_group_id[local.k8s_control_plane_component]
#     }
#   }
#   tag_prefix = local.tag_prefix
# }
# 
# module "k8s-cluster-ec2-worker-node-1" {
#   source = "../../../modules/compute-ec2"
# 
#   subnet_id          = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.k8s_cluster_subnet_name}"]
#   security_group_ids = [module.k8s-cluster-security-groups.security_group_id[local.k8s_worker_node_component]]
#   key_pair_name      = module.k8s-cluster-ssh-public-key.key_pair_name
#   tags = {
#     Name = "${local.tag_prefix}${local.k8s_worker_node_component}"
#     Role = local.k8s_worker_node_component
#   }
# }
