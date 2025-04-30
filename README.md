# Strapi ECS Deployment with AWS

A production-ready deployment solution for Strapi CMS using AWS ECS, Terraform, and GitHub Actions with blue/green deployment support.

## 📋 Table of Contents
- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Infrastructure Components](#infrastructure-components)
- [GitHub Actions Workflow](#github-actions-workflow)
- [Deployment Guide](#deployment-guide)
- [Monitoring & Troubleshooting](#monitoring--troubleshooting)

## 🏗 Architecture Overview

![Architecture Diagram](architecture.png)

Key components:
- ECS Cluster with Fargate
- Application Load Balancer
- CodeDeploy for blue/green deployments
- RDS PostgreSQL database
- ECR for container registry
- VPC with public/private subnets

## 🚀 Prerequisites

1. AWS Account with required permissions
2. GitHub repository
3. Terraform installed locally (for testing)
4. AWS CLI configured

Required GitHub Secrets:
```bash
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

## 🛠 Infrastructure Components

### VPC Configuration (main.tf)
```hcl
- 2 Public Subnets (for ALB)
- 2 Private Subnets (for ECS & RDS)
- NAT Gateway
- Internet Gateway
```

### ECS Setup
```hcl
- Fargate Launch Type
- Blue/Green deployment enabled
- Auto-scaling policies
- CloudWatch logging
```

### Database
```hcl
- RDS PostgreSQL
- Multi-AZ deployment
- Automated backups
- Enhanced monitoring
```

## 👷 GitHub Actions Workflow

Two main workflows:

### 1. Infrastructure Deployment
```yaml
Trigger: Manual (workflow_dispatch)
Action: create-infra
Steps:
  1. Terraform Init
  2. Terraform Plan
  3. Terraform Apply
```

### 2. Application Deployment
```yaml
Trigger: Manual (workflow_dispatch)
Action: deploy-app
Steps:
  1. Get ECS Task Definition
  2. Create CodeDeploy Deployment
  3. Monitor Deployment Status
```

## 📝 Deployment Guide

### First Time Setup

1. Clone the repository:
```bash
git clone https://github.com/your-username/strapi_ecs_deploy.git
cd strapi_ecs_deploy
```

2. Configure GitHub Secrets:
   - Navigate to Repository Settings
   - Add required secrets

3. Create Infrastructure:
   - Go to Actions tab
   - Select "CD - Infrastructure and Deployment"
   - Choose "create-infra"
   - Enter ECR image URI
   - Run workflow

### Regular Deployments

1. Build and push new Strapi image
2. Trigger deployment:
   - Go to Actions tab
   - Select "CD - Infrastructure and Deployment"
   - Choose "deploy-app"
   - Enter new ECR image URI
   - Run workflow

## 🔍 Monitoring & Troubleshooting

### CloudWatch Logs
```bash
# View ECS container logs
aws logs get-log-events \
  --log-group-name /ecs/strapi-service \
  --log-stream-name <container-id>
```

### Deployment Status
```bash
# Check CodeDeploy deployment
aws deploy get-deployment \
  --deployment-id <deployment-id>
```

### Health Checks
```bash
# ALB target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

## 📊 Metrics & Monitoring

- ECS Service Metrics
  - CPU/Memory Utilization
  - Running Task Count
  
- ALB Metrics
  - Request Count
  - Target Response Time
  - HTTP Status Codes

- RDS Metrics
  - CPU Utilization
  - Free Storage Space
  - Database Connections

## ⚠️ Common Issues

1. Deployment Failures
   - Check CodeDeploy events
   - Verify task definition
   - Check container logs

2. Database Connection Issues
   - Verify security group rules
   - Check RDS status
   - Validate connection strings

3. Load Balancer Issues
   - Check target group health
   - Verify security group rules
   - Validate health check settings

## 🔐 Security Best Practices

1. Network Security
   - Private subnets for ECS tasks
   - Security group restrictions
   - HTTPS only

2. Access Control
   - IAM roles with least privilege
   - Secrets in AWS Secrets Manager
   - No hardcoded credentials

3. Monitoring
   - CloudWatch alarms
   - AWS Config rules
   - CloudTrail enabled

## 📦 Resource Cleanup

```bash
# Delete infrastructure
terraform destroy

# Clean up ECR images
aws ecr batch-delete-image \
  --repository-name strapi-app \
  --image-ids imageTag=latest
```

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Strapi Documentation](https://strapi.io/documentation)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.