## 🌲 Architecture Decision Tree

This document outlines the **first-pass decision tree** for the project’s infrastructure and tooling. It maps all key branch points — from orchestration platform to deployment strategies — without yet assigning implications or constraints. This is the "forks on the road" view before dependency analysis in Step 2B.

---

### 📦 Core Infrastructure

```
Infrastructure Provisioning
├── Terraform
│   └── AWS Provider
│       ├── VPC
│       ├── Compute Platform
│       │   ├── EKS (Managed Kubernetes)
│       │   └── EC2 + Docker (manually orchestrated)
│       ├── Load Balancer
│       │   ├── ALB (Application Load Balancer)
│       │   └── K8s Ingress + Service
│       └── Auto-Scaling
│           ├── EKS Node Group (Managed Scaling)
│           └── EC2 ASG
```

---

### 🚀 Application Build & Delivery

```
App Build & Containerization
├── Docker
│   ├── Multi-stage Dockerfile
│   └── Base image: Alpine vs Node-slim

CI/CD Tooling
├── GitHub Actions
│   ├── Manual trigger
│   ├── Push-on-commit to main
│   └── On PR merge to main
└── Alternative CI (not considered)
```

---

### 🧭 Deployment to Cluster

```
Deployment Strategy
├── Standard K8s Deployment
├── Argo Rollouts (Canary)
└── Blue-Green via extra K8s Services
```

---

### 🔒 Secrets Management

```
Secrets Backend
├── AWS Secrets Manager
│   ├── External Secrets Operator
│   └── IAM Role for ServiceAccount
└── K8s Secrets (manually managed)
```

---

### 📈 Monitoring & Observability

```
Metrics Stack
├── Prometheus
│   ├── kube-prometheus-stack Helm chart
│   └── In-cluster deployment via manifests
├── CloudWatch Agent + Logs (fallback)
└── Custom metrics endpoint on app

Dashboards
├── Grafana (via Prometheus stack)
└── Skipped / Stubbed (fallback path)

Alerting
├── Alertmanager → Slack Webhook
└── Email fallback
```

---

### 🔐 HTTPS / TLS

```
TLS Termination
├── cert-manager + Let's Encrypt
│   ├── HTTP-01 Challenge
│   └── DNS-01 Challenge (fallback)
└── Reverse proxy (e.g. Nginx + self-managed certs)
```

---

### 🩺 Health Checks

```
Health Check Integration
├── Kubernetes liveness & readiness probes
└── Argo Rollouts AnalysisTemplate (optional advanced)
```

---

This tree reflects all known branches under consideration before dependency resolution. The next step (2B) will annotate each with implications, gotchas, constraints, and interdependencies — and may reorder some decisions accordingly.

---
