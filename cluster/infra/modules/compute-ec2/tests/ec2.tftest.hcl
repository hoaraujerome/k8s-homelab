run "setup_aws_provider" {
  module {
    source = "../../../../modules/tests/setup/aws_provider"
  }
}

run "check_ec2" {
  variables {
    subnet_id            = "subnetid"
    security_group_ids   = ["sg1", "sg2", "sg3"]
    key_pair_name        = "keypairname"
    iam_instance_profile = "profile"
    tags = {
      Name = "prefix-ec2"
      Role = "myrole"
    }
  }

  command = plan

  assert {
    condition     = aws_instance.this.instance_type == "t4g.small"
    error_message = "Invalid instance type"
  }

  assert {
    condition     = aws_instance.this.subnet_id == var.subnet_id
    error_message = "Invalid instance subnet id"
  }

  assert {
    condition     = aws_instance.this.vpc_security_group_ids == var.security_group_ids
    error_message = "Invalid instance VPC SG ids"
  }

  assert {
    condition     = aws_instance.this.key_name == var.key_pair_name
    error_message = "Invalid instance key name"
  }

  assert {
    condition     = aws_instance.this.associate_public_ip_address == false
    error_message = "Invalid instance associate public IP address"
  }

  assert {
    condition     = aws_instance.this.root_block_device[0].encrypted == true
    error_message = "Invalid instance encrypted for the root block device"
  }

  assert {
    condition     = aws_instance.this.metadata_options[0].http_tokens == "required"
    error_message = "Invalid instance http tokens for metadata options"
  }

  assert {
    condition     = aws_instance.this.metadata_options[0].instance_metadata_tags == "enabled"
    error_message = "Invalid instance metadata tags for metadata options"
  }

  assert {
    condition     = aws_instance.this.ami == data.aws_ami.ubuntu_k8s.id
    error_message = "Invalid instance ami id"
  }

  assert {
    condition     = aws_instance.this.iam_instance_profile == var.iam_instance_profile
    error_message = "Invalid instance IAM instance profile"
  }

  assert {
    condition     = aws_instance.this.tags == var.tags
    error_message = "Invalid instance tags"
  }

  assert {
    condition     = data.aws_ami.ubuntu_k8s.most_recent == true
    error_message = "Invalid ami most recent"
  }

  assert {
    condition     = startswith(data.aws_ami.ubuntu_k8s.name, "ubuntu-2404-") == true
    error_message = "Invalid ami name"
  }

  assert {
    condition     = alltrue([for owner in data.aws_ami.ubuntu_k8s.owners : contains(["self"], owner)])
    error_message = "Invalid ami owners"
  }
}

run "setup_prereq" {
  module {
    source = "./tests/setup/prereq"
  }
}

run "create_ec2" {
  variables {
    subnet_id            = run.setup_prereq.subnet_id
    security_group_ids   = [run.setup_prereq.sg1_id]
    iam_instance_profile = run.setup_prereq.instance_profile_name
  }

  command = apply
}
