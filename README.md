# VHT Community Learning Platform - CI/CD Pipeline

A peer-to-peer learning platform for local communities in Uganda, built on Village Health Teams (VHT) networks and Women Groups with automated CI/CD infrastructure using GitHub Actions and Terraform.

**Author:** Charles Herbert Matovu  
**Created:** 2025

## 📋 Project Overview

This repository contains the Infrastructure as Code (IaC) configuration for the VHT Community Learning Platform. The project aims to:

- Provide accessible peer-to-peer learning resources
- Support Village Health Teams (VHT) networks
- Empower Women Groups in Uganda
- Deploy and manage cloud infrastructure automatically
- Ensure consistent, reproducible deployments

## 🏗️ Architecture

```
├── main.tf              # Core infrastructure resources
├── variables.tf         # Input variables and validations
├── outputs.tf           # Output values
├── backend.tf           # Terraform backend configuration
├── terraform.tfvars.example  # Example variable values
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml      # PR validation workflow
│       ├── terraform-apply.yml     # Production deployment workflow
│       └── terraform-validate.yml  # Code quality checks
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- **Terraform** >= 1.0
- **Google Cloud Platform** (GCP) account with a project
- **GitHub** repository with this code
- **gcloud CLI** installed and authenticated

### Local Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/cicd-terraform.git
   cd cicd-terraform
   ```

2. **Create GCP Service Account:**
   ```bash
   gcloud iam service-accounts create terraform-sa \
     --display-name="Terraform Service Account"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   ```

3. **Setup Workload Identity Federation (GitHub):**
   ```bash
   gcloud iam service-accounts add-iam-policy-binding \
     terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
     --role roles/iam.workloadIdentityUser \
     --member "principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.repository/YOUR_REPO"
   ```

4. **Configure Terraform variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

5. **Initialize Terraform:**
   ```bash
   terraform init
   ```

6. **Plan and apply:**
   ```bash
   terraform plan
   terraform apply
   ```

## 🔐 GitHub Secrets Configuration

Configure these secrets in your GitHub repository settings:

| Secret | Description | Example |
|--------|-------------|---------|
| `GCP_PROJECT_ID` | GCP Project ID | `vht-learning-platform` |
| `GCP_REGION` | GCP Region | `us-central1` |
| `BUCKET_NAME` | GCS Bucket name | `vht-learning-dev` |
| `WIF_PROVIDER` | Workload Identity Provider | `projects/123456/locations/global/workloadIdentityPools/github-pool/providers/github-provider` |
| `WIF_SERVICE_ACCOUNT` | Service Account email | `terraform-sa@vht-project.iam.gserviceaccount.com` |

## 📦 Resources

This Terraform configuration creates:

- **Google Cloud Storage Bucket**: Stores website assets, community resources, and learning materials
  - Versioning enabled for recovery
  - Uniform bucket-level access for security
  - Environment-specific naming
  - Lifecycle policies for production safety

## 🔄 CI/CD Workflows

### 1. Terraform Validate & Format
**Trigger:** Every push to main/develop and PRs

- Validates Terraform syntax
- Checks code formatting
- Runs TFLint for best practices
- Non-blocking for quick feedback

### 2. Terraform Plan
**Trigger:** Pull requests to main/develop

- Authenticates to GCP via Workload Identity
- Generates and displays execution plan
- Comments plan on PR for review
- Prevents unexpected changes

### 3. Terraform Apply
**Trigger:** Push to main branch

- Automatically applies validated changes
- Updates infrastructure in GCP
- Stores state artifacts
- 30-day retention for audit trails

## 📝 Variable Configuration

### Required Variables

```hcl
gcp_project_id = "your-gcp-project"
bucket_name    = "vht-learning-platform-dev"
```

### Optional Variables

```hcl
gcp_region      = "us-central1"        # Default
environment     = "dev"                 # dev, staging, production
force_destroy   = true                  # Allow bucket deletion
enable_versioning = true                # Enable versioning
```

## 🔍 Validation Rules

- **Project ID**: Must match GCP naming conventions
- **Bucket Name**: 3-63 characters, lowercase, hyphens allowed
- **Environment**: Only `dev`, `staging`, or `production`
- **Region**: Valid GCP region

## 📊 Outputs

After applying Terraform, you'll get:

```
bucket_name        = "vht-learning-platform-dev"
bucket_url         = "gs://vht-learning-platform-dev"
bucket_self_link   = "https://www.googleapis.com/storage/v1/b/..."
bucket_location    = "us-central1"
project_id         = "your-gcp-project"
region             = "us-central1"
```

## 🛠️ Common Tasks

### View Current Infrastructure State
```bash
terraform show
```

### Update Variable Value
```bash
terraform apply -var="environment=staging"
```

### Destroy Resources
```bash
terraform destroy
```
⚠️ **Warning**: Use with caution in production!

### Format Code
```bash
terraform fmt -recursive
```

### Validate Configuration
```bash
terraform validate
```

## 📚 Remote State Management

To enable remote state storage on GCS:

1. Create a GCS bucket for state:
   ```bash
   gsutil mb gs://vht-terraform-state
   ```

2. Uncomment `backend` block in `main.tf`

3. Run `terraform init` to migrate state

## 🔒 Security Best Practices

✅ **Implemented:**
- Workload Identity Federation for GitHub (no long-lived credentials)
- Bucket versioning for disaster recovery
- Uniform bucket-level access (ACLs disabled)
- Environment-based resource destruction prevention
- Resource tagging for cost tracking
- Terraform state stored remotely (optional)

✏️ **Recommendations:**
- Use separate GCP projects for dev/staging/production
- Enable GCP organization policies
- Regular Terraform plan reviews in PRs
- Implement drift detection and monitoring
- Maintain audit logs of all deployments

## 📖 Documentation Links

- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GitHub Actions Setup](https://github.com/hashicorp/setup-terraform)
- [GCP Workload Identity Federation](https://cloud.google.com/docs/authentication/workload-identity-federation)
- [Google Cloud Storage](https://cloud.google.com/storage/docs)

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make changes and test locally: `terraform plan`
3. Commit with clear messages: `git commit -m "Add new resource"`
4. Push and create a Pull Request
5. Wait for CI/CD validation to pass
6. Request review from team members
7. Merge once approved

## 📄 License

This project is maintained by Charles Herbert Matovu (2025).

## 📞 Support

For issues and questions:
- Open a GitHub issue
- Check existing documentation
- Review Terraform logs: `TF_LOG=DEBUG terraform plan`

---

**Last Updated:** January 2026  
**Terraform Version:** >= 1.0  
**GCP Provider:** >= 5.0
