output "security_group_id" {
  value = { for name, sg in aws_security_group.this : name => sg.id }
}
