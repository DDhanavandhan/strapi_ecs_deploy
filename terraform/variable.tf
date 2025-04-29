variable "aws_region" {
  default = "us-east-1"
}

variable "ecr_image" {
  description = "The full ECR image URI including tag to deploy"
  type        = string
  default     = 626635402783.dkr.ecr.us-east-1.amazonaws.com / strapi-app
}

variable "app_port" {
  default = 1337
}
variable "domain_name" {
  default = "nsmstore.site"
}
