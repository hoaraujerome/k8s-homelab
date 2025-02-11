run "setup_provider" {
  module {
    source = "../../tests/setup/aws_provider"
  }
}

run "setup_key" {
  module {
    source = "./tests/setup/key"
  }
}

run "check_ssh_key_pair" {
  variables {
    public_key_path = run.setup_key.ssh_public_key_filename
    tag_prefix      = "prefix-"
  }

  command = plan

  assert {
    condition     = aws_key_pair.ssh.key_name == "${var.tag_prefix}ssh-key-pair"
    error_message = "Invalid key pair key name"
  }

  assert {
    condition     = aws_key_pair.ssh.public_key == run.setup_key.ssh_public_key_content
    error_message = "Invalid key pair public key"
  }

  assert {
    condition     = output.key_pair_name == aws_key_pair.ssh.key_name
    error_message = "Invalid ouput key pair name"
  }
}

run "create_ssh_key_pair" {
  variables {
    public_key_path = "../../tests/id_rsa_test.pub"
  }

  command = apply
}
