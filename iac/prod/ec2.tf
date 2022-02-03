## CORE VPC STATE
data "terraform_remote_state" "dsf" {
  backend = "s3"
  config = {
    bucket  = "dsf-terraform-state"
    key     = "core/prod/terraform.tfstate"
    region  = "us-east-1"
  }
}

## Key Pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "foundry-key" {
  key_name    = "foundry-access-key"
  public_key  = tls_private_key.key.public_key_openssh
}

## EC2
data "aws_ami" "foundry" {
  owners      = ["self"]
  most_recent = true
  
  filter {
    name    = "name"
    values  = [
      "foundry-v${var.foundry-major-v}.*"
    ]
  }
}

resource "aws_instance" "foundry" {
  ami                         = data.aws_ami.foundry.id
  availability_zone           = var.availability-zone
  instance_type               = var.ec2-type
  subnet_id                   = data.terraform_remote_state.dsf.outputs.public_subnet_id
  key_name                    = aws_key_pair.foundry-key.key_name
  associate_public_ip_address = true

  user_data = templatefile("../scripts/startup.tftpl", {
    serverdir: var.foundry-server-dir,
    datadevicename: var.ebs-data-device-name,
    fstype: var.ebs-data-fstype,
    datadir: var.foundry-data-dir,
    port: var.foundry-port,
    servicefile: var.foundry-service-filename
  })
  
  vpc_security_group_ids = [
    data.terraform_remote_state.dsf.outputs.security_group_id
  ]

  root_block_device {
    volume_size           = "8" # GiB
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = var.availability-zone
  size = var.ebs-data-size

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Type = "data"
  }
}

resource "aws_ebs_snapshot" "data" {
  volume_id = aws_ebs_volume.data.id
}

resource "aws_volume_attachment" "data" {
  device_name = var.ebs-data-device-name
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.foundry.id

  stop_instance_before_detaching = true
}