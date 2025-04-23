## 🧰 Tooling & Local Preflight

This document outlines the required tooling for local development and evaluation, as well as the preflight setup needed to prepare for provisioning and deployment in later steps.

---

### 🛠️ Tooling Stack Overview

| Layer              | Tool / Platform                       | Notes                                                                 |
|--------------------|----------------------------------------|-----------------------------------------------------------------------|
| IaC                | **Terraform** (v1.6+)                  | Used for AWS infra provisioning (VPC, EKS, IAM, ECR, etc.)           |
| K8s CLI            | **kubectl**, **eksctl** (optional)     | Required to interact with EKS cluster                                |
| Container Build    | **Docker** (multi-stage build)         | Standard Docker-based image creation                                 |
| CI/CD              | **GitHub Actions**                     | YAML-based pipelines triggered on push to `main`                     |
| Registry           | **Amazon ECR**                         | Target for Docker image uploads                                      |
| Deployment Engine  | **Argo Rollouts**                      | Progressive rollout via CRDs and controller                          |
| TLS                | **cert-manager**                       | Manages Let's Encrypt TLS certs inside K8s                           |
| Secrets            | **AWS Secrets Manager + ExternalSecrets** | Secrets pulled into cluster with IRSA + sync operator             |
| Monitoring         | **Prometheus + Grafana (Helm chart)**  | Metrics stack deployed via Helm or raw manifests                     |
| Alerting           | **Alertmanager + Slack Webhook**       | Simple alerting path with high demo visibility                       |

---

### ⚙️ Local Pre-Flight Setup

Before provisioning begins, install the following locally:

```bash
brew install terraform kubectl helm awscli
```

Authenticate to AWS:

```bash
aws configure
```

Optional (for debugging or EKS GUI setup):

```bash
brew install eksctl
```

---

This preflight checklist ensures the local environment is properly equipped to begin infrastructure provisioning and cluster setup in Step 4.

---
