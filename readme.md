# Strapi Infrastructure Project

This repository contains infrastructure setup for a Strapi application using Terraform for AWS deployment and local development configuration.

## 📁 Project Structure

```
.
├── task_1/                  # Strapi Application Setup
│   ├── config/             # Strapi configuration files
│   ├── src/                # Source code
│   │   ├── admin/         # Admin panel customizations
│   │   └── api/           # API endpoints
│   └── strapi-lookup/     # Strapi example implementation
│
└── task_2/                # Infrastructure Setup
    ├── main.tf            # Main Terraform configuration
    ├── variables.tf       # Terraform variables
    ├── output.tf          # Terraform outputs
    └── install_data.sh    # Server setup script
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v16.x or later)
- npm or yarn
- Terraform
- AWS CLI configured
- PostgreSQL (for local development)

### Local Development Setup

1. Clone the repository
2. Navigate to the Strapi application directory:
```bash
cd task_1/strapi-lookup
```

3. Install dependencies:
```bash
npm install
# or
yarn install
```

4. Start the development server:
```bash
npm run develop
# or
yarn develop
```

### Infrastructure Deployment

1. Navigate to the infrastructure directory:
```bash
cd task_2
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the infrastructure plan:
```bash
terraform plan
```

4. Apply the infrastructure:
```bash
terraform apply
```

## 🛠️ Configuration

### Strapi Configuration

The Strapi application can be configured through the following files:
- `config/admin.ts` - Admin panel settings
- `config/database.ts` - Database configuration
- `config/server.ts` - Server settings
- `config/middlewares.ts` - Middleware configuration

### Infrastructure Configuration

Infrastructure settings can be modified in:
- `task_2/variables.tf` - Terraform variables
- `task_2/install_data.sh` - Server setup script

## 📝 Scripts

### Strapi Scripts

- `npm run develop` - Start development server
- `npm run build` - Build the application
- `npm run start` - Start production server
- `npm run deploy` - Deploy the application

### Infrastructure Scripts

- `terraform init` - Initialize Terraform workspace
- `terraform plan` - Preview infrastructure changes
- `terraform apply` - Apply infrastructure changes
- `terraform destroy` - Remove infrastructure

## 🔒 Security

- Environment variables should be properly configured
- AWS credentials should be securely managed
- Database credentials should be kept secure
- SSL/TLS should be enabled in production

## 📚 Documentation

- [Strapi Documentation](https://docs.strapi.io)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Node.js Documentation](https://nodejs.org/docs)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the Mozilla Public License Version 2.0 - see the LICENSE file for details.