variable "domain_name" {
  description = "my domain name"
  type        = string
  default     = "temijimi.me"
}

# get the zone id
resource "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name
  
  tags = {
        Enviroment = "dev"
        }
}

# create a record set in route 53
# terraform  aws_route53_record
resource "aws_route53_record"  "site_domain" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "terraform-test.${var.domain_name}"
  type    = "A"

    alias {
        name                   = aws_lb.Altschool-Assignment_lb.dns_name
        zone_id                = aws_lb.Altschool-Assignment_lb.zone_id
        evaluate_target_health = true
    }
}
