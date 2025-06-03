output "instance_ip_addr_public" {
  value = aws_eip.final-assignment-eip.public_ip
}

output "instance_ip_addr_private" {
  value = aws_instance.bastion-instance.private_ip
}