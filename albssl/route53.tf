resource "aws_route53_record" "this" {
  name            = module.ctx.domain
  zone_id         = data.aws_route53_zone.public.zone_id
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb.lb_dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "www" {
  name            = format("www.%s", module.ctx.domain)
  zone_id         = data.aws_route53_zone.public.zone_id
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb.lb_dns_name]
  allow_overwrite = true
}
