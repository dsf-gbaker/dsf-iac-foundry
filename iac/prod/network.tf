# Load Balancer / Listeners / Target Groups
resource "aws_lb_target_group" "foundry-http" {
  port      = 80
  protocol  = "HTTP"
  vpc_id    = data.terraform_remote_state.dsf.outputs.vpc_id

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
    data.terraform_remote_state.dsf.outputs.security_group_id
  ]
  subnets = [
    data.terraform_remote_state.dsf.outputs.public_subnet_id,
    data.terraform_remote_state.dsf.outputs.public_subnet_id2
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