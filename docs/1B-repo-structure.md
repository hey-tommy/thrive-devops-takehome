## 🗂️ Project Directory Layout

This layout scaffolds the base structure of the submission repository. It ensures all required deliverables — Terraform, app code, CI/CD, monitoring, documentation — are clearly organized for reviewer access.

This structure may evolve slightly during architecture finalization (Step 3C), but this baseline reflects the known deliverables and planning conventions from Step 1A.

```bash
thrive-devops-takehome/
├── infra/                   # Infrastructure-as-Code (Terraform)
│   └── terraform/           # Modularized Terraform files
├── k8s/                     # Kubernetes manifests
│   ├── base/                # Base K8s deployments/services
│   ├── rollouts/            # Argo Rollouts CRs and templates
│   └── secrets/             # Secret manifests (ExternalSecrets, K8s Secrets)
├── monitoring/              # Prometheus rules, Grafana dashboards, alertmanager config
│   └── helm-values.yaml
├── app/                     # App Dockerfile, source, health probe scripts
│   ├── Dockerfile
│   └── server.js
├── .github/                 # GitHub Actions workflows
│   └── workflows/
├── docs/                    # Documentation artifacts
│   ├── ADRs/                # Architecture Decision Records
│   └── diagrams/            # System diagrams (.drawio, .png, or .mmd)
├── .env.example             # Safe template for env vars
├── README.md                # Main project overview & instructions
├── CONTRIBUTING.md          # Contributor/deployment guidance
├── NOTES.md                 # Internal notes & time log (not for eval)
├── EVALUATOR.md             # Optional evaluator context / walk-through
```

---

**Notes:**

- The `infra/terraform/` directory is expected to include isolated modules or staged layers (e.g., `vpc.tf`, `eks.tf`, etc.)
- `k8s/secrets/` will be populated only after architecture finalization confirms use of AWS Secrets Manager + external-secrets operator.
- The `monitoring/` folder is reserved for alert rules, dashboards, and service monitors (if used).
- `EVALUATOR.md` is optional but can help surface strategic intent or clarify known gaps.
