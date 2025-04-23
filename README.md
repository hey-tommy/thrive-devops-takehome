# 🚀 Thrive DevOps Take-Home Assignment

This repository contains my submission for the DevOps/MLOps take-home assignment for Thrive Career Wellness.

---

## 📐 Architecture Overview

> _Note: This section will be updated to reflect final design._

- **Platform**: AWS (EKS, VPC, IAM)
- **IaC**: Terraform
- **Deployment**: Kubernetes (Argo Rollouts)
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana
- **Secrets Management**: AWS Secrets Manager + External Secrets
- **Bonus Features**: TLS (cert-manager), Canary deployments, Health checks

---

## 🧠 Design Goals

- Showcase layered, production-grade DevOps workflows
- Emphasize traceability, documentation, and progressive delivery
- Prioritize polish, structure, and strategic signaling within time constraints

---

## 📦 How to Deploy _(in progress)_

```bash
# 1. Clone the repo
git clone https://github.com/your-username/thrive-devops-takehome.git
cd thrive-devops-takehome

# 2. Setup AWS credentials
export AWS_PROFILE=your-profile-name

# 3. Provision Infrastructure
cd infra/terraform
terraform init
terraform apply

# 4. Deploy App
kubectl apply -f k8s/base/
```

---

📊 Monitoring & Alerting

This section will link to dashboards or alert configs once finalized.

	•	Prometheus: basic CPU/memory metrics
	•	Grafana: sample dashboard + placeholder JSON
	•	Alerts: webhook-based + optional email route

---

🔐 Secrets

Stubbed for now — will be wired into external-secrets operator.

	•	AWS Secrets Manager
	•	.env.example included for local reference

---

🧪 Rollouts & Health Checks
	•	Canary deployment via Argo Rollouts
	•	Health checks and analysis templates to be documented

---

📝 Docs & Commentary

File/Section	Description
README.md	Project overview (this file)
docs/plan.md	Execution plan & strategy
docs/ADRs/	Architecture decision records
docs/diagrams/	System and deployment diagrams (TBD)
EVALUATOR.md	(optional) Supplementary context for reviewers

---

✅ Status

Layer	State
Core Infrastructure	🔧 In Progress
CI/CD Pipeline	⏳ Upcoming
Monitoring + Alerts	⏳ Upcoming
Bonus Features	⏳ Planning
Polish & Docs	✍️ Ongoing

---

🙏 Thanks!

Thanks again for the opportunity — I’m excited to demonstrate how I think about infrastructure, automation, and scalable DevOps practices.