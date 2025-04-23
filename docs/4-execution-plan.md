## 🪜 Layered Execution Plan & Rationale

This document outlines the planned execution flow for the project — broken into clear, dependency-aligned layers. Each layer builds on the last and is sequenced to maximize momentum, reduce cognitive load, and allow for clean fallback if time runs short.

This is not a list of to-dos. It’s a **strategic execution scaffold** designed to:

- Unblock the highest-leverage components early
- Frontload infrastructure and deployment realism
- Build visible polish and evaluative signal over time

---

### 🟢 Layer 1: Must-Haves

These tasks are foundational. Everything else depends on them being complete.

| Task                                | Purpose                                         | Blocking Dependencies       |
|-------------------------------------|-------------------------------------------------|-----------------------------|
| Terraform: VPC + EKS + IAM          | Core infrastructure + cluster provisioning      | None                        |
| Terraform: ECR                      | Required for CI/CD pipeline image pushes        | None                        |
| Dockerfile + Node.js app            | Base container for deployment                   | None                        |
| `kubectl` context setup             | Enables K8s interaction post-cluster creation   | EKS                         |
| Argo Rollouts CRD install           | Enables progressive deployment via K8s          | EKS                         |
| Deploy base app via Rollout YAML   | Smoke test deployment & traffic routing         | Cluster + Rollouts CRD      |

---

### 🔵 Layer 2: Strategic Core

These tasks deliver the strongest signal-to-effort payoff. They’re prioritized immediately after Layer 1.

| Task                                | Purpose                                         | Blocking Dependencies       |
|-------------------------------------|-------------------------------------------------|-----------------------------|
| GitHub Actions CI pipeline          | Automated image build → push → deploy           | Dockerfile, ECR, Kubeconfig |
| Prometheus install + config         | Metrics collection for Argo + observability     | Cluster + App               |
| Alertmanager + Slack webhook        | High-visibility alert mechanism                 | Prometheus                  |
| Grafana dashboard (optional)        | Bonus polish if Prometheus succeeds             | Prometheus                  |

---

### 🟡 Layer 3: High-Signal Extras

These are evaluative accelerators. They deliver high polish or depth, but depend on Layer 1 and 2.

| Task                                | Purpose                                         | Blocking Dependencies       |
|-------------------------------------|-------------------------------------------------|-----------------------------|
| cert-manager + ClusterIssuer        | TLS termination and HTTPS                       | Ingress + DNS (optional)    |
| External Secrets Operator + IRSA   | K8s-native secrets pull from AWS Secrets Manager| IAM + ServiceAccount        |
| Argo AnalysisTemplate               | Metrics-based rollout validation and rollback   | Prometheus + Rollouts       |

> Note: All of these may be stubbed with clearly documented fallbacks or `# TODO:` comments if time becomes constrained.

---

### 🔴 Optional Flair

This layer is for anything time-permitting that demonstrates creativity, initiative, or extra polish. It should only be pursued once all of Layer 1–3 are in place or safely stubbed.

| Idea                                | Purpose                                         | Notes                       |
|-------------------------------------|-------------------------------------------------|-----------------------------|
| A/B rollout demo via Argo Experiments | Signals future-facing orchestration readiness | Extremely high signal       |
| Bonus Argo UI screenshots or Loom demo | Reviewer optics, clarity                      | Use `NOTES.md` or `EVALUATOR.md` |
| ChatGPT agent in CI step             | Novelty / charm play                           | Only if <90 min remain       |

---

### Degradation Strategy

Each layer boundary acts as a **scope checkpoint**. If time or AWS billing thresholds are reached:

- Close out in-place features cleanly
- Document unimplemented items visibly in README or ADR
- Include stubs or mocked outputs (e.g., sample Prometheus alert rule YAML)
- Flag intent, not absence — show judgment, not omission

---
