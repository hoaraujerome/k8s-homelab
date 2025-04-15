packer {
  required_plugins {
    amazon = {
      version = "~> 1.3.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  default = "ca-central-1"
}

variable "vpc_id" {
  default = "vpc-083e2ba257765a249"
}

variable "subnet_id" {
  default = "subnet-027a214259a9047cb"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws"
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
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}
