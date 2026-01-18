#!/usr/bin/env pwsh
# VHT Learning Platform - Windows Setup Script
# For PowerShell on Windows

Write-Host "🚀 VHT Community Learning Platform - Windows Setup" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

# Check Terraform
Write-Host "📋 Checking Terraform installation..." -ForegroundColor Yellow
try {
    $tfVersion = terraform --version | Select-Object -First 1
    Write-Host "✅ $tfVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform not found. Download from: https://www.terraform.io/downloads" -ForegroundColor Red
    exit 1
}

# Check gcloud
Write-Host "📋 Checking gcloud CLI installation..." -ForegroundColor Yellow
try {
    $gcVersion = gcloud --version | Select-Object -First 1
    Write-Host "✅ $gcVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ gcloud CLI not found. Download from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Red
    exit 1
}

# Create terraform.tfvars if needed
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host ""
    Write-Host "📝 Creating terraform.tfvars from example..." -ForegroundColor Yellow
    Copy-Item "terraform.tfvars.example" "terraform.tfvars"
    Write-Host "⚠️  Please edit terraform.tfvars with your values" -ForegroundColor Yellow
    Write-Host ""
}

# Initialize Terraform
Write-Host ""
Write-Host "🔧 Initializing Terraform..." -ForegroundColor Yellow
terraform init

# Validate
Write-Host ""
Write-Host "✔️  Validating Terraform configuration..." -ForegroundColor Yellow
terraform validate

# Format check
Write-Host ""
Write-Host "📐 Checking code formatting..." -ForegroundColor Yellow
try {
    terraform fmt -check -recursive
    Write-Host "✅ Code formatting OK" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Formatting issues found. Run: terraform fmt -recursive" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Edit terraform.tfvars with your GCP details"
Write-Host "   2. Run: terraform plan"
Write-Host "   3. Review the output"
Write-Host "   4. Run: terraform apply"
Write-Host ""
Write-Host "🔗 Documentation:" -ForegroundColor Cyan
Write-Host "   - Full Guide: README.md"
Write-Host "   - Deployment: DEPLOYMENT.md"
Write-Host "   - Project Info: PROJECT.md"
Write-Host "   - CI/CD Setup: CICD_SETUP.md"
Write-Host "   - Structure: STRUCTURE.md"
Write-Host ""
