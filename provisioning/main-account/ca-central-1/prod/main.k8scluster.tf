module "k8s-cluster-ssh-public-key" {
  source = "../../../modules/compute-sshpublickey"

  public_key_path = var.ssh_public_key_path
  tag_prefix      = local.tag_prefix
}

module "k8s-cluster-ec2-control-plane-security-groups" {
  source = "../../../modules/network-securitygroup"

  vpc_id     = module.vpc.vpc_id
  names      = [local.k8s_control_plane_component]
  tag_prefix = local.tag_prefix
}

module "k8s-cluster-ec2-control-plane-security-group-rules" {
  source = "../../../modules/network-securitygrouprules"

  security_group_id = module.k8s-cluster-ec2-control-plane-security-groups.security_group_id[local.k8s_control_plane_component]
  rules = {
    "ssh-inbound-traffic" = {
      description                  = "Allows inbound SSH traffic from the resources associated with the endpoint security group"
      direction                    = "inbound"
      from_port                    = local.ssh_port
      to_port                      = local.ssh_port
      ip_protocol                  = local.tcp_protocol
      referenced_security_group_id = module.ec2-instance-connect-endpoint-security-groups.security_group_id[local.ec2_instance_connect_endpoint_component]
    }
  }
  tag_prefix = local.tag_prefix
}

module "k8s-cluster-ec2-control-plane" {
  source = "../../../modules/compute-ec2"

  subnet_id          = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.k8s_cluster_subnet_name}"]
  security_group_ids = [module.k8s-cluster-ec2-control-plane-security-groups.security_group_id[local.k8s_control_plane_component]]
  key_pair_name      = module.k8s-cluster-ssh-public-key.key_pair_name
  tags = {
    Name = "${local.tag_prefix}${local.k8s_control_plane_component}"
    Role = local.k8s_control_plane_component
  }
}
