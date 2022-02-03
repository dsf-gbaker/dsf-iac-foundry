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