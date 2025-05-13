packer {
  required_plugins {
    amazon = {
      version = "~> 1.3.6"
      source  = "github.com/hashicorp/amazon"
    }

    ansible = {
      version = "~> 1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "region" {
  default = "ca-central-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-2404-{{timestamp}}"
  instance_type = "t4g.small"
  region        = var.region
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "../ansible/node.yaml"
  }
}
