# load balancer output

output "elb_dns_name" {
  value = aws_lb.Altschool-Assignment_lb.dns_name
}

output "elb_zone_id" {
  value = aws_lb.Altschool-Assignment_lb.zone_id
}

output "elb_target_group_arn" {
    value = aws_lb_target_group.Altschool-Assignment_target_group.arn
}