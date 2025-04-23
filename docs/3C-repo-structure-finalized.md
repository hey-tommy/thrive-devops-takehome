## 🗂️ Final Directory Structure & Purpose

This structure reflects the finalized project layout based on the selected architecture: **EKS + Argo Rollouts + Prometheus + GitHub Actions + AWS Secrets Manager**. Each directory supports a clean, evaluable submission and aligns with standard DevOps repo patterns.

```bash
thrive-devops-takehome/
├── infra/                      # Infrastructure-as-Code
│   └── terraform/              # Terraform modules (VPC, EKS, IAM, etc.)
│       ├── main.tf             # Entry point for provisioning
│       ├── variables.tf        # Input variables
│       ├── outputs.tf          # Output values for pipeline integration
│       └── ...                 # Module files (split as needed)
│
├── k8s/                        # Kubernetes manifests
│   ├── base/                   # Core deployment: app, service, ingress
│   ├── rollouts/               # Argo Rollouts CRDs + AnalysisTemplates
│   └── secrets/                # ExternalSecret + fallback k8s Secret specs
│
├── monitoring/                 # Observability stack config
│   ├── prometheus-rules/       # Custom alert rules
│   ├── grafana-dashboards/     # Optional JSON dashboards
│   └── alertmanager/           # Alertmanager config for Slack webhook
│
├── app/                        # Application code and containerization
│   ├── Dockerfile              # Multi-stage build
│   ├── server.js               # Basic Node.js hello world app
│   └── healthz/                # Health probe routes/scripts
│
├── .github/                    # CI/CD workflows
│   └── workflows/              # GitHub Actions YAML pipelines
│       └── deploy.yml
│
├── scripts/                    # Helper CLI scripts (e.g. bootstrap, log dump)
│   └── deploy.sh
│
├── docs/                       # Planning, architecture, and rationale
│   ├── ADRs/                   # Architecture Decision Records
│   ├── diagrams/               # System diagrams (.drawio, .png, or .mmd)
│   └── ...                     # Planning markdowns (e.g., validation, risk log)
│
├── .env.example                # Safe environment variable template
├── README.md                   # Main project readme with usage & diagrams
├── CONTRIBUTING.md             # Setup + evaluation guide (optional)
├── EVALUATOR.md                # Optional context/walkthrough for reviewers
├── NOTES.md                    # Internal dev log (not intended for evaluation)
```

---

### Design Principles

- **Evaluator-oriented layout**: Each major feature (infra, app, K8s, monitoring) is clearly isolated
- **Toolchain-agnostic naming**: Directories use purpose-driven names (`infra/`, not `terraform/`)
- **Kubernetes-first**: K8s structure allows easy apply/swap, works with GitOps or manual workflows
- **Graceful fallback**: `secrets/` and `monitoring/` can be stubs if needed without breaking directory logic

---
