#!/bin/bash
# VHT Community Learning Platform - Kubernetes Quick Start
# Deploys to a 3-node GKE cluster

set -e

echo "🚀 VHT Community Learning Platform - Kubernetes Deployment"
echo "============================================================"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

command -v gcloud >/dev/null 2>&1 || { echo "❌ gcloud CLI not found"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm not found"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "❌ terraform not found"; exit 1; }

echo "✅ All prerequisites met"
echo ""

# Step 1: Initialize Terraform
echo "1️⃣  Initializing Terraform for GKE cluster..."
terraform init

# Step 2: Plan and apply
echo "2️⃣  Planning infrastructure deployment..."
terraform plan -var-file=terraform.tfvars -out=tfplan

echo ""
echo "📋 Please review the plan above and confirm deployment"
read -p "Continue with deployment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

echo "3️⃣  Creating GKE cluster with 3 nodes..."
terraform apply tfplan

# Get cluster info
CLUSTER_NAME="vht-learning-platform-dev"
REGION="us-central1"
PROJECT_ID=$(gcloud config get-value project)

echo "4️⃣  Configuring kubectl..."
gcloud container clusters get-credentials $CLUSTER_NAME \
    --region $REGION \
    --project $PROJECT_ID

echo "5️⃣  Verifying cluster..."
kubectl cluster-info
echo ""
echo "Node status:"
kubectl get nodes -o wide

echo ""
echo "6️⃣  Deploying application to Kubernetes..."
kubectl create namespace vht-community || true

# Deploy with Helm
helm upgrade --install vht-platform ./helm/vht-platform \
    --namespace vht-community \
    --values helm/vht-platform/values.yaml \
    --wait \
    --timeout 10m

echo ""
echo "7️⃣  Verifying deployment..."
kubectl rollout status deployment/vht-platform -n vht-community

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📊 Deployment Status:"
kubectl get deployment vht-platform -n vht-community -o wide
echo ""
echo "📦 Pod Status:"
kubectl get pods -n vht-community -l app=vht-platform
echo ""
echo "🌐 Service Status:"
kubectl get svc vht-platform-service -n vht-community
echo ""
echo "🎯 Next steps:"
echo "1. Get external IP: kubectl get svc -n vht-community vht-platform-service"
echo "2. View logs: kubectl logs -n vht-community -l app=vht-platform"
echo "3. Scale replicas: kubectl scale deployment vht-platform --replicas=5 -n vht-community"
echo "4. Monitor: kubectl top pods -n vht-community"
echo ""
