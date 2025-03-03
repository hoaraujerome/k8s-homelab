locals {
  tag_prefix                              = "k8s-homelab-"
  k8s_cluster_subnet_name                 = "k8s-cluster"
  ec2_instance_connect_endpoint_component = "ec2-instance-connect-endpoint"
  k8s_control_plane_component             = "k8s-control-plane"
  ssh_port                                = 22
  tcp_protocol                            = "tcp"
}
