output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "autoscaling_group_name" {
  value = module.autoscaling.autoscaling_group_name
}
