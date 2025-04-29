variable "aws_region" {
  default = "us-east-1"
}

variable "ecr_image" {
  description = "The full ECR image URI including tag to deploy"
  type        = string
}

variable "app_port" {
  default = 1337
}

variable "ecr_image" {
  description = "ECR Image URL"
  type        = string
}

variable "domain_name" {
  default = "nsmstore.site"
}
