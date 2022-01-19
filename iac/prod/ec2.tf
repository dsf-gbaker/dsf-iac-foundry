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
data "aws_ami" "foundry" {
  owners      = ["self"]
  most_recent = true
  
  filter {
    name    = "name"
    values  = [
      "foundry-v${var.foundry-major-v}.${var.foundry-minor-v}"
    ]
  }
}

resource "aws_instance" "foundry-ec2" {
  ami                         = data.aws_ami.foundry.id
  availability_zone           = var.availability-zone
  instance_type               = var.ec2-type
  subnet_id                   = aws_subnet.public.id
  key_name                    = aws_key_pair.foundry-key.key_name
  associate_public_ip_address = true

  user_data = templatefile("../scripts/startup.tftpl", {
    serverdir: var.foundry-server-dir,
    datadir: var.foundry-data-dir,
    port: var.foundry-port
  })
  
  vpc_security_group_ids = [
    aws_security_group.foundry-sg.id
  ]

  root_block_device {
    volume_size     = "8" # GiB
    volume_type     = "gp2"
  }
}

resource "aws_eip" "foundry-ip" {
  instance  = aws_instance.foundry-ec2.id
  vpc       = true
}

resource "aws_route53_record" "foundry" {
  zone_id   = "Z32FUY4DHGYU8I"
  name      = "vtt.digitalsloth.com"
  type      = "A"
  ttl       = "300"
  records   = [
    aws_eip.foundry-ip.public_ip
  ]
}