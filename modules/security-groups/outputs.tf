output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

