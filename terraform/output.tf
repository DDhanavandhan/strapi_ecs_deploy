# Output the public ALB DNS name
output "strapi_url" {
  value = "http://${aws_lb.alb.dns_name}"
}

output "code_deploy_app_name" {
  value = aws_codedeploy_app.strapi.name
}

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.strapi.deployment_group_name
}