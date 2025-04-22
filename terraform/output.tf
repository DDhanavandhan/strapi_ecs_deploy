# Output the public ALB DNS name
output "strapi_url" {
  value = "http://${aws_lb.alb.dns_name}"
}