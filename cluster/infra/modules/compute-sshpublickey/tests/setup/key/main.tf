terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
  }
}

resource "local_file" "ssh_public_key" {
  content  = "foo"
  filename = "${path.module}/ssh.pub"
}

output "ssh_public_key_filename" {
  value = local_file.ssh_public_key.filename
}

output "ssh_public_key_content" {
  value = local_file.ssh_public_key.content
}
