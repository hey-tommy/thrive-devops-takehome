# 📋 Requirements Checklist

This checklist includes all **explicit**, **implicit**, and **bonus** requirements extracted from the take-home assignment. Bonus items are treated as must-haves unless deprioritized in a fallback layer. Each item is labeled by type.

---

### 🟢 Core Infrastructure Requirements (Explicit)

- [ ] Provision infrastructure using **Terraform**
- [ ] Use **AWS** (fresh account, free tier if possible)
- [ ] Provision a **Virtual Private Cloud (VPC)**
- [ ] Deploy a **container orchestration platform** (EKS preferred)
- [ ] Include a **load balancer**
- [ ] Support **auto-scaling** (either ASG or K8s node pools)

---

### 🔵 Application Deployment (Explicit)

- [ ] Deploy a basic **Hello World Node.js** app
- [ ] Containerize the app using **Docker**
- [ ] Deploy the containerized app via **Kubernetes**
- [ ] Use a **CI/CD pipeline** to:
  - [ ] Build Docker image
  - [ ] Push to a container registry (ECR or Docker Hub)
  - [ ] Deploy to the cluster

---

### 🟡 Monitoring & Alerting (Explicit)

- [ ] Expose **basic metrics** (CPU, memory, req/sec)
- [ ] Set up **basic alerting** (email or Slack webhook acceptable)

---

### 🟣 Bonus Features (Treated as Mandatory if Time Allows)

- [ ] Add **HTTPS/TLS** using `cert-manager` or reverse proxy
- [ ] Implement **canary or blue-green deployments**
- [ ] Integrate with a **secrets manager** (e.g. AWS Secrets Manager, Vault)
- [ ] Add **health checks** for the app

---

### 🟠 Submission & Documentation Requirements (Explicit)

- [ ] GitHub repository must include:
  - [ ] `README.md` explaining architecture, how to deploy, and where to view metrics/alerts
  - [ ] All infra code, Dockerfiles, K8s manifests or Compose files, CI/CD configs
  - [ ] Diagrams or trade-off notes for decisions made
  - [ ] **Replication instructions** for deploying to a fresh AWS account
