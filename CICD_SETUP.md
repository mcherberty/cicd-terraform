# CI/CD Configuration Guide

## GitHub Actions Secrets Setup

Add these secrets to your GitHub repository to enable automatic deployment.

### How to Add Secrets

1. Go to your repository on GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret below

### Required Secrets

#### `GCP_PROJECT_ID`
Your Google Cloud Platform project ID.

```
Example: vht-learning-platform-prod
```

**How to find:**
```bash
gcloud config get-value project
```

---

#### `GCP_REGION`
Google Cloud region for resource deployment.

```
Example: us-central1
Alternative: us-east1, europe-west1, asia-south1
```

**Recommended regions for Africa:**
- `africa-south1` (South Africa)
- `us-east1` (Good latency for East Africa)
- `europe-west1` (Alternative)

---

#### `BUCKET_NAME`
Unique name for the GCS bucket storing your platform data.

```
Example: vht-learning-platform-prod
Rules: lowercase, 3-63 chars, hyphens allowed
```

**Naming convention:**
```
vht-learning-{environment}-{region}
Examples:
- vht-learning-prod-us
- vht-learning-staging-eu
- vht-learning-dev-local
```

---

#### `WIF_PROVIDER`
Workload Identity Federation provider resource name.

```
Example: projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider
```

**How to get:**
```bash
gcloud iam workload-identity-pools providers describe github-provider \
  --project=YOUR_PROJECT_ID \
  --location=global \
  --workload-identity-pool=github-pool \
  --format='value(name)'
```

---

#### `WIF_SERVICE_ACCOUNT`
Service account email for GitHub Actions authentication.

```
Example: terraform-sa@vht-learning-platform-prod.iam.gserviceaccount.com
```

**Format:** `SERVICE_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com`

**How to get:**
```bash
gcloud iam service-accounts list --format='value(email)'
```

---

## GitHub Environment Secrets

For different environments (dev, staging, production), use GitHub environments:

### Create Environments

1. Settings → Environments
2. Create new environment (dev, staging, production)
3. Add environment-specific secrets

### Environment-Specific Configuration

#### Development
```
BUCKET_NAME: vht-learning-dev
force_destroy: true
```

#### Staging
```
BUCKET_NAME: vht-learning-staging
force_destroy: true
```

#### Production
```
BUCKET_NAME: vht-learning-prod
force_destroy: false  # Prevent accidental deletion
```

---

## Workflow Triggers

### terraform-validate.yml
- **Trigger:** Every push and PR to main/develop
- **Purpose:** Code quality and syntax validation
- **No GCP credentials needed**

### terraform-plan.yml
- **Trigger:** Pull requests to main/develop
- **Purpose:** Show planned changes
- **Requires:** All 5 secrets above
- **Output:** Plan comments on PR

### terraform-apply.yml
- **Trigger:** Push to main branch only
- **Purpose:** Automatic infrastructure deployment
- **Requires:** All 5 secrets above
- **Safety:** Review plan in PR before merge

---

## Configuring Workload Identity Federation

### One-Time Setup (Terraform Admin)

```bash
#!/bin/bash
PROJECT_ID="your-gcp-project-id"
REPO_OWNER="your-github-username"
REPO_NAME="cicd-terraform"

# Set project
gcloud config set project $PROJECT_ID

# Create service account
gcloud iam service-accounts create terraform-sa \
  --display-name="GitHub Actions Terraform"

# Grant storage permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --project=$PROJECT_ID \
  --location=global \
  --display-name="GitHub"

# Create provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project=$PROJECT_ID \
  --location=global \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,assertion.aud=assertion.aud" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Get WIF Provider
WIF_PROVIDER=$(gcloud iam workload-identity-pools providers describe github-provider \
  --project=$PROJECT_ID \
  --location=global \
  --workload-identity-pool=github-pool \
  --format='value(name)')

echo "WIF_PROVIDER=$WIF_PROVIDER"

# Bind GitHub to service account
gcloud iam service-accounts add-iam-policy-binding \
  terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_ID}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${REPO_OWNER}/${REPO_NAME}"

echo "✅ Workload Identity Federation configured!"
echo "Service Account: terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com"
echo "WIF Provider: $WIF_PROVIDER"
```

---

## Testing the Setup

### Test Plan Workflow

1. Create a feature branch: `git checkout -b test/ci-setup`
2. Make a small change to a `.tf` file
3. Push and create a PR
4. Check GitHub Actions → terraform-plan
5. Review the plan output

### Test Apply Workflow

1. Merge PR to main
2. Check GitHub Actions → terraform-apply
3. Verify resources created in GCP Console

---

## Monitoring Deployments

### GitHub Actions Dashboard
- Go to Actions tab in your repository
- Click on a workflow run to see logs
- Check for errors in job output

### GCP Console
- Go to Cloud Storage to verify buckets
- Check service account roles
- Review API quotas

### Local Testing
```bash
# Test Terraform locally before pushing
terraform plan -var-file=terraform.tfvars
terraform validate
terraform fmt -check

# Debug GitHub Actions locally (optional)
# Install: brew install act
act -j plan
```

---

## Troubleshooting CI/CD

### "Authentication failed"
- Check GCP_PROJECT_ID matches actual project
- Verify WIF_PROVIDER and WIF_SERVICE_ACCOUNT
- Ensure service account has correct roles

### "Bucket already exists"
- Bucket names are globally unique
- Add timestamp or random suffix
- Check GCS for existing buckets

### "Permission denied"
- Verify service account roles in GCP
- Check Workload Identity binding
- Ensure principal set matches repository

### Workflow not triggering
- Check branch name (main, not master)
- Verify file paths in workflow trigger
- Ensure GitHub Actions enabled in settings

---

## Cost Monitoring

GitHub Actions provides:
- **Public Repos:** Free CI/CD minutes
- **Private Repos:** 2,000 minutes/month free

GCP Free Tier includes:
- **Cloud Storage:** 5 GB storage
- **Network:** 1 GB egress per month

**Estimate monthly costs:**
- Small platform: <$5
- Medium platform: $10-50
- Large platform: $50-200+

Monitor in GCP Console → Billing.

---

## Security Best Practices

✅ **Implemented:**
- Workload Identity (no long-lived credentials)
- Short-lived GitHub tokens (1 hour)
- Separate service accounts per environment
- Repository branch protection rules

✏️ **Recommended:**
- Enable branch protection on main
- Require PR reviews before merge
- Use environment-specific secrets
- Rotate credentials quarterly
- Enable GCP audit logging

---

For issues or questions, check:
1. [README.md](README.md)
2. [DEPLOYMENT.md](DEPLOYMENT.md)
3. GitHub Actions workflow logs
4. GCP Cloud Logs

---

**Last Updated:** January 2026
