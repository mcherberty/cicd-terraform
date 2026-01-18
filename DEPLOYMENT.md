# Terraform Configuration for VHT Learning Platform

## Deployment Guide

### Step 1: GCP Setup

```bash
# Set your project ID
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID

# Create service account
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"
```

### Step 2: Workload Identity Federation (for GitHub)

```bash
# Create workload identity pool
gcloud iam workload-identity-pools create "github-pool" \
  --project=$PROJECT_ID \
  --location=global \
  --display-name="GitHub Pool"

# Create workload identity provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project=$PROJECT_ID \
  --location=global \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,assertion.aud=assertion.aud" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Get the WIF provider resource name
WIF_PROVIDER=$(gcloud iam workload-identity-pools providers describe github-provider \
  --project=$PROJECT_ID \
  --location=global \
  --workload-identity-pool=github-pool \
  --format='value(name)')

echo "WIF_PROVIDER=$WIF_PROVIDER"
```

### Step 3: Configure GitHub Actions

1. Go to Repository Settings → Secrets and Variables → Actions
2. Add these secrets:
   - `GCP_PROJECT_ID`: Your GCP project ID
   - `GCP_REGION`: Region (e.g., us-central1)
   - `BUCKET_NAME`: Unique bucket name
   - `WIF_PROVIDER`: From Step 2
   - `WIF_SERVICE_ACCOUNT`: terraform-sa@{PROJECT_ID}.iam.gserviceaccount.com

### Step 4: Local Testing

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

## Monitoring & Maintenance

### View Terraform State

```bash
terraform state list
terraform state show google_storage_bucket.vht_learning_bucket
```

### Check Applied Resources

```bash
gsutil ls -L gs://YOUR_BUCKET_NAME
```

### Destroy Infrastructure

```bash
terraform destroy
```

## Troubleshooting

### Authentication Error

```bash
# Re-authenticate with gcloud
gcloud auth application-default login

# Verify service account
gcloud iam service-accounts list
```

### State Lock Issue

```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### TF Plan Changes Not Applied

- Check GitHub Actions logs
- Verify GCP credentials
- Ensure service account has correct roles

## Cost Optimization

- Use `force_destroy = false` in production
- Enable bucket versioning only when needed
- Set lifecycle policies for old versions
- Monitor GCS usage in GCP Console

---

For more details, see [README.md](README.md)
