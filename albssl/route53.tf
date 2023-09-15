resource "aws_route53_record" "this" {
  name    = module.ctx.domain
  zone_id = data.aws_route53_zone.public.zone_id
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
  # allow_overwrite = true
}

resource "aws_route53_record" "www" {
  name    = format("www.%s", module.ctx.domain)
  zone_id = data.aws_route53_zone.public.zone_id
  type    = "A"
  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
