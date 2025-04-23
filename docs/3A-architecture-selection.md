## 🏗️ Final Architecture Path Selection

This document records the final architecture path selected for the take-home assignment. Each component was chosen to balance realism, clarity, and signal strength — while remaining achievable within a limited time window. Bonus features are included where feasible or stubbed with explanatory fallback.

---

### ☁️ Infrastructure & Orchestration Stack

| Category             | Choice                    | Rationale                                                                 |
|----------------------|---------------------------|---------------------------------------------------------------------------|
| IaC Tool             | **Terraform**             | Industry standard; allows modular infra definition + reuse                |
| Cloud Provider       | **AWS (new account)**     | Required by assignment; reflects real-world environment                   |
| Cluster Platform     | **EKS (managed K8s)**     | High realism, aligns with MLOps use cases                                 |
| Load Balancer        | **ALB (via K8s Service)** | Canonical choice for K8s+AWS; integrates cleanly with Ingress controller |
| Auto-scaling         | **EKS Managed Node Groups** | Simplifies scaling and signals platform fluency                          |

---

### 🚀 App Delivery & CI/CD

| Category             | Choice                  | Rationale                                                             |
|----------------------|-------------------------|-----------------------------------------------------------------------|
| Containerization     | **Docker (multi-stage)**| Lightweight, modern build process                                     |
| CI/CD System         | **GitHub Actions**       | Familiar to reviewers, clear YAML semantics                           |
| Registry             | **ECR**                  | Native to AWS; avoids Docker Hub rate limits                          |
| Deployment Strategy  | **Argo Rollouts (Canary)** | Bonus item; high signal and aligns with progressive delivery best practices |

---

### 🔐 Secrets & TLS

| Category             | Choice                                      | Rationale                                                            |
|----------------------|---------------------------------------------|----------------------------------------------------------------------|
| Secrets Management   | **AWS Secrets Manager + External Secrets Operator** | Reflects production MLOps practices; adds IAM complexity    |
| TLS / HTTPS          | **cert-manager + Let’s Encrypt**            | High polish; automatically managed certs without manual intervention |

---

### 📈 Observability

| Category             | Choice                         | Rationale                                                             |
|----------------------|----------------------------------|----------------------------------------------------------------------|
| Metrics Stack        | **Prometheus + Grafana**        | Gold standard for K8s; tight Argo integration                        |
| Alerting             | **Alertmanager → Slack Webhook**| Fast to configure; high signal with minimal overhead                 |

---

### 🩺 Health & Validation

| Category             | Choice                                 | Rationale                                                             |
|----------------------|------------------------------------------|----------------------------------------------------------------------|
| Health Checks        | **K8s probes + Argo AnalysisTemplate**   | Enables progressive rollout validation and rollback capability       |
| Fallback Plan        | **Stub analysis if metrics not ready**   | Graceful degradation strategy                                        |

---

### 🗑️ Rejected or Deferred Options

| Option                          | Reason for Rejection / Deferment                                  |
|----------------------------------|--------------------------------------------------------------------|
| Docker on EC2                   | Lower realism, poor signal vs. EKS                                 |
| Blue-Green Deployment           | Requires parallel infra setup and manual service switch            |
| K8s Secrets (manual)            | Acceptable fallback but lacks integration realism                  |
| Email-based Alerting            | Less evaluable and harder to demo than Slack webhook               |
| Reverse Proxy TLS Termination   | Requires custom Nginx + manual certs; less polished                |

---

### ⚙️ Bonus Feature Summary

| Feature                | Status        | Notes                                                        |
|------------------------|---------------|--------------------------------------------------------------|
| TLS / HTTPS            | ✅ Planned     | Full integration using cert-manager                          |
| Canary Deployments     | ✅ Planned     | Full rollout via Argo Rollouts                               |
| Secrets Integration    | ✅ Planned     | Will use External Secrets + IAM role binding                 |
| Health Checks          | 🟡 Partial     | Probes will be included; Argo Analysis may be stubbed        |

---

### 🧭 Deployment Strategy Justification: Argo Rollouts (Canary)

This project uses **Argo Rollouts for canary deployments**, rather than alternatives like Blue-Green or ALB-only traffic shifting.

See detailed analysis in [docs/ADRs/0001-canary-eks-rationale.md](ADRs/0001-canary-eks-rationale.md) for a full comparison, but in brief:

- **Progressive delivery with metrics-based rollback** adds realism and signal
- **Declarative, GitOps-compatible CRDs** are future-proof and observable
- **A/B testing extensibility** via `Experiment` steps is built-in
- **Reviewer "wow" factor** is highest — visible, live rollout control

This architecture intentionally leans into **modern infrastructure orchestration** to demonstrate judgment, not just implementation speed.

---
