# 📋 Requirements Checklist

This checklist includes all **explicit**, **implicit**, and **bonus** requirements extracted from the take-home assignment. Bonus items are treated as must-haves unless deprioritized in a fallback layer. Each item is labeled by type.

---

### 🟢 Core Infrastructure Requirements (Explicit)

- [x] Provision infrastructure using **Terraform**
- [x] Use **AWS** (fresh account, free tier if possible)
- [x] Provision a **Virtual Private Cloud (VPC)**
- [x] Deploy a **container orchestration platform** (EKS preferred)
- [x] Include a **load balancer**
- [x] Support **auto-scaling** (either ASG or K8s node pools)

---

### 🔵 Application Deployment (Explicit)

- [x] Deploy a basic **Hello World Node.js** app
- [x] Containerize the app using **Docker**
- [x] Deploy the containerized app via **Kubernetes**
- [x] Use a **CI/CD pipeline** to:
  - [x] Build Docker image
  - [x] Push to a container registry (ECR or Docker Hub)
  - [x] Deploy to the cluster

---

### 🟡 Monitoring & Alerting (Explicit)

- [ ] Expose **basic metrics** (CPU, memory, req/sec)
- [x] Set up **basic alerting** (email or Slack webhook acceptable)

---

### 🟣 Bonus Features (Treated as Mandatory if Time Allows)

- [ ] Add **HTTPS/TLS** using `cert-manager` or reverse proxy
- [x] Implement **canary or blue-green deployments**
- [x] Integrate with a **secrets manager** (e.g. AWS Secrets Manager, Vault)
- [x] Add **health checks** for the app

---

### 🟠 Submission & Documentation Requirements (Explicit)

- [x] GitHub repository must include:
  - [x] `README.md` explaining architecture, how to deploy, and where to view metrics/alerts
  - [x] All infra code, Dockerfiles, K8s manifests or Compose files, CI/CD configs
  - [x] Diagrams or trade-off notes for decisions made
  - [x] **Replication instructions** for deploying to a fresh AWS account
