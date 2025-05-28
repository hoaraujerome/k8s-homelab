data "aws_ami" "ubuntu_k8s" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["ubuntu-2404-*"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu_k8s.id
  instance_type               = "t4g.small"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_pair_name
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  tags = var.tags
}
