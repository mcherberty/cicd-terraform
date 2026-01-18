# Kubernetes Deployment Guide

## Overview

The VHT Community Learning Platform is now configured for deployment on a 3-node Kubernetes cluster running on Google Kubernetes Engine (GKE).

**Author:** Charles Herbert Matovu  
**Created:** 2025  
**Platform:** Kubernetes on GCP

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│         Google Kubernetes Engine (GKE) Cluster          │
│                   3 Nodes (e2-standard-2)               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │        vht-community Namespace                   │  │
│  ├──────────────────────────────────────────────────┤  │
│  │                                                  │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │   VHT Platform Deployment (3 Pods)     │    │  │
│  │  │  - Pod 1: Running                       │    │  │
│  │  │  - Pod 2: Running                       │    │  │
│  │  │  - Pod 3: Running                       │    │  │
│  │  │                                         │    │  │
│  │  │  HPA: Min 3, Max 9 replicas             │    │  │
│  │  │  CPU: 70% target, Memory: 80% target    │    │  │
│  │  └─────────────────────────────────────────┘    │  │
│  │          ↓                                        │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │     Load Balancer Service               │    │  │
│  │  │     Type: LoadBalancer                  │    │  │
│  │  │     Port: 80/443                        │    │  │
│  │  └─────────────────────────────────────────┘    │  │
│  │          ↓                                        │  │
│  │  ┌─────────────────────────────────────────┐    │  │
│  │  │     Ingress (nginx-ingress)             │    │  │
│  │  │     Host: vht-learning.example.com      │    │  │
│  │  │     TLS: Let's Encrypt (cert-manager)   │    │  │
│  │  └─────────────────────────────────────────┘    │  │
│  │                                                  │  │
│  │  Supporting Services:                           │  │
│  │  - Redis (StatefulSet, 1 replica)              │  │
│  │  - PostgreSQL (StatefulSet, 1 replica)         │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### Required Tools
- `gcloud` CLI (Google Cloud SDK)
- `kubectl` (Kubernetes CLI)
- `helm` (Kubernetes package manager)
- `docker` (for building images)

### GCP Requirements
- Active GCP project with billing enabled
- Service account with necessary permissions
- Container Registry enabled
- Kubernetes Engine API enabled

### Installation

```bash
# Install gcloud SDK
curl https://sdk.cloud.google.com | bash

# Install kubectl
gcloud components install kubectl

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installations
gcloud version
kubectl version --client
helm version
```

---

## Deployment Steps

### Step 1: Provision GKE Cluster

Using Terraform to create the 3-node cluster:

```bash
cd cicd-terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=terraform.tfvars

# Apply Kubernetes infrastructure
terraform apply -var-file=terraform.tfvars
```

This creates:
- 3-node GKE cluster (e2-standard-2 machines)
- VPC network with subnets
- Node pools with auto-scaling (3-9 nodes)
- Network policies and security groups

### Step 2: Configure kubectl Access

```bash
# Get cluster credentials
gcloud container clusters get-credentials vht-learning-platform-dev \
  --region us-central1 \
  --project YOUR_GCP_PROJECT_ID

# Verify connection
kubectl cluster-info
kubectl get nodes
```

Expected output:
```
NAME                                          STATUS   ROLES    AGE
gke-vht-learning-platform-dev-node-pool-xxx   Ready    <none>   5m
gke-vht-learning-platform-dev-node-pool-xxx   Ready    <none>   5m
gke-vht-learning-platform-dev-node-pool-xxx   Ready    <none>   5m
```

### Step 3: Deploy Application

#### Option A: Using Helm (Recommended)

```bash
# Create namespace
kubectl create namespace vht-community

# Deploy with Helm
helm install vht-platform ./helm/vht-platform \
  --namespace vht-community \
  --values helm/vht-platform/values.yaml

# Verify deployment
helm list -n vht-community
kubectl get all -n vht-community
```

#### Option B: Using kubectl manifests

```bash
# Create namespace and deploy
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/services.yaml
kubectl apply -f k8s/policies.yaml
kubectl apply -f k8s/ingress.yaml

# Check status
kubectl get deployments -n vht-community
kubectl get pods -n vht-community
kubectl get svc -n vht-community
```

### Step 4: Verify Deployment

```bash
# Check deployment status
kubectl rollout status deployment/vht-platform -n vht-community

# View pods
kubectl get pods -n vht-community -o wide

# Check services
kubectl get svc -n vht-community

# View logs
kubectl logs -n vht-community -l app=vht-platform --tail=50

# Port forward for testing
kubectl port-forward -n vht-community svc/vht-platform-service 8080:80
curl http://localhost:8080
```

---

## 3-Node Deployment Details

### Node Configuration

```yaml
Machine Type: e2-standard-2
  - 2 vCPU
  - 8 GB memory
  - 50 GB disk

Count: 3 minimum
Auto-scaling: 3-9 nodes based on load
```

### Pod Distribution

```
Node 1: vht-platform-pod-1, redis-pod, postgres-pod
Node 2: vht-platform-pod-2
Node 3: vht-platform-pod-3
```

### Pod Specifications

```yaml
Replicas: 3 (rolling updates)
  - Min: 3
  - Max: 9 (via HPA)

Resources per Pod:
  - CPU Request: 250m
  - CPU Limit: 500m
  - Memory Request: 256Mi
  - Memory Limit: 512Mi

Probes:
  - Liveness: /health (30s initial delay)
  - Readiness: /ready (10s initial delay)

Affinity:
  - Pod anti-affinity (spread across nodes)
  - Prefer different nodes for availability
```

---

## Scaling & Auto-scaling

### Horizontal Pod Autoscaling (HPA)

```bash
# View current HPA status
kubectl get hpa -n vht-community

# Edit HPA
kubectl edit hpa vht-platform-hpa -n vht-community

# Manual scaling
kubectl scale deployment vht-platform \
  --replicas=6 \
  -n vht-community
```

### Node Auto-scaling

The cluster automatically scales nodes between 3-9 based on:
- CPU utilization > 70%
- Memory utilization > 80%
- Pod pending due to insufficient resources

---

## Configuration

### Secrets Management

Secrets are stored in Kubernetes Secrets:

```bash
# View secrets
kubectl get secrets -n vht-community

# Update a secret
kubectl patch secret vht-platform-secrets \
  -n vht-community \
  -p='{"data":{"DATABASE_PASSWORD":"'$(echo -n "new-password" | base64)'"}}'

# Delete and recreate
kubectl delete secret vht-platform-secrets -n vht-community
kubectl create secret generic vht-platform-secrets \
  --from-literal=DATABASE_USER=vht_user \
  --from-literal=DATABASE_PASSWORD=new-password \
  -n vht-community
```

### ConfigMap Updates

```bash
# View config
kubectl get configmap vht-platform-config -n vht-community -o yaml

# Update config
kubectl patch configmap vht-platform-config \
  -n vht-community \
  -p='{"data":{"LOG_LEVEL":"debug"}}'
```

---

## Monitoring & Logging

### View Logs

```bash
# All pods
kubectl logs -n vht-community -l app=vht-platform

# Specific pod
kubectl logs -n vht-community POD_NAME

# Streaming logs
kubectl logs -n vht-community -l app=vht-platform -f

# Previous pod (if crashed)
kubectl logs -n vht-community POD_NAME --previous
```

### Access Metrics

```bash
# Pod metrics (requires metrics-server)
kubectl top nodes
kubectl top pods -n vht-community

# Detailed pod information
kubectl describe pod POD_NAME -n vht-community
```

### Port Forwarding

```bash
# Access service locally
kubectl port-forward -n vht-community \
  svc/vht-platform-service 8080:80

# Access specific pod
kubectl port-forward -n vht-community \
  POD_NAME 8080:3000
```

---

## Updating Deployment

### Rolling Updates

```bash
# Update image
kubectl set image deployment/vht-platform \
  vht-platform=gcr.io/PROJECT_ID/vht-platform:v1.1 \
  -n vht-community

# Check rollout status
kubectl rollout status deployment/vht-platform -n vht-community

# Rollback if needed
kubectl rollout undo deployment/vht-platform -n vht-community

# View rollout history
kubectl rollout history deployment/vht-platform -n vht-community
```

### Using Helm Updates

```bash
# Update Helm repository
helm repo update

# Upgrade release
helm upgrade vht-platform ./helm/vht-platform \
  --namespace vht-community \
  --values helm/vht-platform/values.yaml

# Rollback
helm rollback vht-platform -n vht-community
```

---

## Networking

### Accessing the Application

```bash
# Get external IP
kubectl get svc -n vht-community vht-platform-service

# Add to /etc/hosts (for local DNS)
echo "34.95.1.2 vht-learning.example.com" | sudo tee -a /etc/hosts
```

### Network Policies

The deployment includes network policies:

```yaml
- Ingress: Allow from ingress-nginx and vht-community namespace
- Egress: Allow to Redis, PostgreSQL, and DNS
- Pod-to-pod communication enabled
```

---

## Security

### RBAC (Role-Based Access Control)

```bash
# Create service account
kubectl create serviceaccount vht-platform -n vht-community

# Create role binding
kubectl create rolebinding vht-platform-binding \
  --clusterrole=pod-reader \
  --serviceaccount=vht-community:vht-platform \
  -n vht-community
```

### Pod Security Policies

- Non-root user (UID 1001)
- Read-only root filesystem
- No privileged containers
- Dropped capabilities (ALL)

### Network Security

- Network policies enabled
- Private cluster recommended
- GCP firewall rules configured
- TLS encryption (cert-manager + Let's Encrypt)

---

## Backup & Disaster Recovery

### Database Backups

```bash
# Create backup
kubectl exec -n vht-community postgres-0 -- \
  pg_dump -U vht_user vht_community > backup.sql

# Restore from backup
kubectl exec -n vht-community postgres-0 -- \
  psql -U vht_user vht_community < backup.sql
```

### Persistent Volume Snapshots

```bash
# View persistent volumes
kubectl get pv -n vht-community

# Create snapshot (GCP-specific)
gcloud compute disks snapshot DISK_NAME \
  --snapshot-names=vht-backup-$(date +%s)
```

---

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl describe pod POD_NAME -n vht-community

# Check events
kubectl get events -n vht-community --sort-by='.lastTimestamp'

# Check resource limits
kubectl top pods -n vht-community

# Check logs
kubectl logs POD_NAME -n vht-community --previous
```

### Connection Issues

```bash
# Test DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  nslookup vht-platform-service.vht-community.svc.cluster.local

# Test connectivity
kubectl exec -it POD_NAME -n vht-community -- \
  curl http://vht-platform-service:80/health
```

### Persistent Volume Issues

```bash
# Check PVCs
kubectl get pvc -n vht-community

# Check PV status
kubectl get pv

# Describe PVC
kubectl describe pvc PVC_NAME -n vht-community
```

---

## Cost Optimization

### Recommendations

1. **Use Preemptible Nodes**: 60-70% cost savings
   ```bash
   # Update variable
   kubernetes_preemptible = true
   ```

2. **Right-size Resources**:
   ```yaml
   # Adjust limits in values.yaml
   resources:
     requests:
       cpu: 100m      # Reduced from 250m
       memory: 128Mi   # Reduced from 256Mi
   ```

3. **Enable Cluster Autoscaling**: Only pay for needed nodes

4. **Use Committed Use Discounts**: 25-70% savings on multi-year commitments

---

## Maintenance

### Cluster Upgrades

```bash
# Check available updates
gcloud container clusters list

# Upgrade control plane
gcloud container clusters upgrade vht-learning-platform-dev \
  --master \
  --cluster-version=1.28.0

# Upgrade nodes
gcloud container clusters upgrade vht-learning-platform-dev \
  --node-pool=vht-learning-platform-node-pool
```

### Health Checks

```bash
# Cluster health
gcloud container clusters describe vht-learning-platform-dev

# Node health
kubectl get nodes -o wide

# Pod health
kubectl get pods -n vht-community --all-namespaces
```

---

## Cleanup

### Remove Application

```bash
# Delete with Helm
helm uninstall vht-platform -n vht-community

# Or with kubectl
kubectl delete -f k8s/
```

### Destroy Cluster

```bash
# Terraform destroy
terraform destroy -var-file=terraform.tfvars

# Or manual GCP deletion
gcloud container clusters delete vht-learning-platform-dev \
  --region us-central1
```

---

## Support & Documentation

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- Project Repository: [GitHub](https://github.com/vht-learning/platform)

---

**Created by:** Charles Herbert Matovu  
**Community:** Village Health Teams & Women Groups in Uganda  
**Vision:** Peer-to-peer learning through accessible cloud infrastructure

---
