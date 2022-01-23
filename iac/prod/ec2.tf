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

resource "aws_instance" "foundry" {
  ami                         = data.aws_ami.foundry.id
  availability_zone           = var.availability-zone
  instance_type               = var.ec2-type
  subnet_id                   = aws_subnet.public.id
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
    aws_security_group.foundry-sg.id
  ]

  root_block_device {
    volume_size           = "8" # GiB
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

resource "aws_route53_record" "foundry" {
  zone_id   = "Z32FUY4DHGYU8I"
  name      = "vtt.digitalsloth.com"
  type      = "A"

  alias {
    name    = aws_lb.foundry.dns_name
    zone_id = var.hosted-zone-id
    evaluate_target_health = true
  }   
}

# Load Balancer / Listeners / Target Groups
resource "aws_lb_target_group" "foundry-http" {
  port      = 80
  protocol  = "HTTP"
  vpc_id    = aws_vpc.foundry.id

  health_check {
    path    = "/"
    matcher = "200-399"
  }
}

resource "aws_lb" "foundry" {
  name                = "foundry-lb"
  internal            = false
  load_balancer_type  = "application"
  security_groups = [
    aws_security_group.foundry-sg.id
  ]
  subnets = [
    aws_subnet.public.id,
    aws_subnet.public2.id
  ]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "https" {
  load_balancer_arn   = aws_lb.foundry.arn
  port                = "443"
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2016-08"
  certificate_arn     = var.ssl-cert-arn

  default_action {
    target_group_arn  = aws_lb_target_group.foundry-http.arn
    type = "forward"
  } 
}

# redirect 80 to 443
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.foundry.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "foundry" {
  target_group_arn  = aws_lb_target_group.foundry-http.arn
  target_id         = aws_instance.foundry.id
  port              = 80

  depends_on = [
    aws_instance.foundry,
    aws_lb_target_group.foundry-http
  ]
}

resource "aws_ebs_volume" "data" {
  // snapshot_id = data.aws_ebs_snapshot.data-snapshot != null ? data.aws_ebs_snapshot.data-snapshot.id : null
  availability_zone = var.availability-zone
  size = var.ebs-data-size

  tags = {
    Type = "Data"
  }
}

resource "aws_ebs_snapshot" "data" {
  volume_id = aws_ebs_volume.data.id
}

/*
data "aws_ebs_snapshot" "data-snapshot" {
  most_recent = true
  
  filter {
    name    = "tag:Environment"
    values  = [var.environment]
  }

  filter {
    name    = "tag:Name"
    values  = [var.project-name]
  }

  filter {
    name    = "tag:Type"
    values  = ["Data"]
  }

  depends_on = [
    aws_ebs_snapshot.data
  ]
}
*/

resource "aws_volume_attachment" "data" {
  device_name = var.ebs-data-device-name
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.foundry.id

  stop_instance_before_detaching = true
}