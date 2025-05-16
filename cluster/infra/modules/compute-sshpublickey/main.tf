resource "aws_key_pair" "ssh" {
  key_name   = "${var.tag_prefix}ssh-key-pair"
  public_key = file(var.public_key_path)
}
