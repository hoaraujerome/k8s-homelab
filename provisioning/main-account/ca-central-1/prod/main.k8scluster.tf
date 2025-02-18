locals {
  k8s_control_plane_component = "k8s-control-plane"
}

module "k8s-cluster-ssh-public-key" {
  source = "../../../modules/compute-sshpublickey"

  public_key_path = var.ssh_public_key_path
  tag_prefix      = local.tag_prefix
}

module "k8s-cluster-ec2-control-plane" {
  source = "../../../modules/compute-ec2"

  subnet_id = module.vpc.subnet_ids_by_name["${local.tag_prefix}${local.k8s_cluster_subnet_name}"]
  # security_group_ids          = [module.k8s-security-groups.security_group_id[local.k8s_control_plane_component]]
  # key_pair_name               = module.bastion-ssh-public-key.key_pair_name
  # associate_public_ip_address = false
  tags = {
    Name = "${local.tag_prefix}${local.k8s_control_plane_component}"
    Role = local.k8s_control_plane_component
  }
}
