resource "aws_route53_record" "foundry" {
  zone_id   = var.hosted-zone-id
  name      = "vtt.digitalsloth.com"
  type      = "A"

  alias {
    name    = aws_lb.foundry.dns_name
    zone_id = aws_lb.foundry.zone_id
    evaluate_target_health = true
  }   
}