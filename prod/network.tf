# Load Balancer / Listeners / Target Groups
resource "aws_lb_target_group" "foundry" {
  port      = 80
  protocol  = "HTTP"
  vpc_id    = data.terraform_remote_state.dsf.outputs.vpc_id

  health_check {
    path    = "/"
    matcher = "200-399"
  }
}

resource "aws_lb_target_group_attachment" "foundry" {
  target_group_arn  = aws_lb_target_group.foundry.arn
  target_id         = aws_instance.foundry.id
  port              = 80

  depends_on = [
    aws_instance.foundry,
    aws_lb_target_group.foundry
  ]
}

resource "aws_lb_listener_rule" "foundry" {
  listener_arn      = data.terraform_remote_state.dsf.outputs.alb_listener_https_arn
  priority          = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.foundry.arn
  }

  condition {
    host_header {
      values = [
        "vtt.digitalsloth.com"
      ]
    } 
  }
}