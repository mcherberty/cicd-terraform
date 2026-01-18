#!/bin/bash
# VHT Learning Platform - Quick Setup Script
# Run this script to initialize the project locally

set -e  # Exit on error

echo "🚀 VHT Community Learning Platform - Setup Script"
echo "=================================================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform not found. Please install Terraform."; exit 1; }
command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI not found. Please install Google Cloud SDK."; exit 1; }

echo "✅ Terraform version: $(terraform --version | head -n 1)"
echo "✅ gcloud version: $(gcloud --version | head -n 1)"
echo ""

# Create terraform.tfvars if it doesn't exist
if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "⚠️  Please edit terraform.tfvars with your values"
    echo ""
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo ""
echo "✔️  Validating Terraform configuration..."
terraform validate

# Format check
echo ""
echo "📐 Checking code formatting..."
terraform fmt -check -recursive || {
    echo "⚠️  Formatting issues found. Run 'terraform fmt -recursive' to fix."
}

echo ""
echo "✅ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "   1. Edit terraform.tfvars with your GCP project details"
echo "   2. Run: terraform plan"
echo "   3. Review the plan output"
echo "   4. Run: terraform apply"
echo ""
echo "🔗 Documentation:"
echo "   - Full Guide: see README.md"
echo "   - Deployment: see DEPLOYMENT.md"
echo "   - Project Info: see PROJECT.md"
echo ""
