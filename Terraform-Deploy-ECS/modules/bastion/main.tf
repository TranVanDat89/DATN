provider "aws" {
  region = var.region
}

resource "aws_key_pair" "final-assignment-keypair" {
  key_name   = "final-assignment-keypair"
  public_key = file("${path.module}/keypair/final-assignment-key.pub")
}

resource "aws_instance" "bastion-instance" {
  ami           = var.amis[var.region]
  instance_type = var.instance_type
  key_name      = aws_key_pair.final-assignment-keypair.key_name
  tags = {
    Name = "DevOps Bastion"
  }
  vpc_security_group_ids = var.security_groups
  subnet_id = var.subnet_id
  associate_public_ip_address = true
}

resource "aws_eip" "final-assignment-eip" {
  instance = aws_instance.bastion-instance.id
}