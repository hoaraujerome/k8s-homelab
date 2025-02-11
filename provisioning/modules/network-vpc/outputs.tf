output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids_by_name" {
  value = { for s in aws_subnet.this : s.tags["Name"] => s.id }
}
