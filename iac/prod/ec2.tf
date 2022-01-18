## Key Pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "foundry-key" {
  key_name    = "foundry-efs-access-key"
  public_key  = tls_private_key.key.public_key_openssh
}

## EC2
resource "aws_instance" "foundry-ec2" {
  ami                         = var.ec2-ami
  availability_zone           = var.availability-zone
  instance_type               = var.ec2-type
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.foundry-key.key_name
  associate_public_ip_address = true

  user_data = templatefile("../scripts/mount-efs.tftpl", {
    efs: aws_efs_file_system.foundry-efs.id
  })
  
  vpc_security_group_ids = [
    aws_security_group.foundry-sg.id
  ]

  root_block_device {
    volume_size     = "8" # GiB
    volume_type     = "gp2"
  }
}