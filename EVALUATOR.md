# 🚩 Evaluator Quick Guide
This guide will help you quickly and effectively verify that the project meets the evaluation criteria.

---

## ✅ Recommended Evaluation Checklist

> **Note:** Before starting, ensure prerequisite tools (Terraform, AWS CLI, kubectl, Helm) are installed. See [README Quick Start →](README.md#quick-start-guide) if unsure.

| Step | What to Verify | How to Verify (Quickly) | ✅ |
|------|----------------|-------------------------|----|
| 1 | **Infrastructure Setup (Terraform)** | Run `terraform apply` (from Quick Start). Confirm resources created (VPC, EKS, ECR) either via CLI (`terraform state list`) or AWS Console. |  |
| 2 | **IAM/OIDC Configuration** | In AWS IAM Console, quickly confirm IAM Role for GitHub Actions and OIDC Provider configured as documented in README.md Quick Start. |  |
| 3 | **CI/CD Pipeline Functionality** | Go to GitHub Actions, verify recent run success (green ✅), and confirm Docker images pushed to ECR. |  |
| 4 | **Application Deployment** | Run `kubectl get svc` and verify application is reachable at Load Balancer URL. Confirm "Hello World" appears. |  |
| 5 | **Monitoring Setup (Grafana)** *(optional)* | Run provided `kubectl port-forward` commands (see README). Log in and briefly verify Grafana dashboard loads with metrics displayed. |  |

---

## 🕐 How long will this evaluation take?
- Minimal verification: ~10–15 minutes  
- Full verification (with monitoring): ~25–30 minutes  

---

## 📖 Where to Go Next?

- **[README Quick Start Guide →](README.md#quick-start-guide)** _Detailed, step-by-step deployment commands._
- **[Architecture Decision Records (ADRs) →](docs/ADRs/)** _Detailed rationale behind infrastructure and CI/CD choices._

---

## 🚀 Recommended Evaluation Path:

*(Summary walkthrough of the above detailed checklist steps, for quick reference during evaluation.)*

1. Review the project structure and [README.md](README.md) (especially Quick Start).
   - _Initial command:_ `git clone https://github.com/hey-tommy/thrive-devops-takehome.git` (or your fork)
   - *Expected Outcome:* All steps complete without error.
2. Confirm infrastructure via Terraform (`terraform apply`).
   - *Expected Outcome:* Successful resource creation (verify VPC, EKS, ECR in AWS console - optional).
   - Verify GitHub Actions IAM Role and OIDC setup in AWS IAM console (see README Quick Start for setup instructions).
   - Verify External Secrets Operator installation in Kubernetes (detailed step in Quick Start Guide).
3. Validate deployment via GitHub Actions.
   - *Expected Outcome:* Successful workflow run (✅ green checkmarks on 'build' and 'deploy' steps) in the repository's Actions tab.
4. Verify application functionality via Kubernetes (`kubectl get svc`).
   - *Expected Outcome:* Application responds with "Hello World" at the Load Balancer URL.
5. Optional: Explore Grafana dashboard (`kubectl port-forward`).
   - *Expected Outcome:* Grafana login successful, dashboards show Kubernetes metrics.
   - *Grafana Login:* Username: `admin`, Password retrieved via command below.
   - _Commands:_
     ```bash
     # Forward Grafana port
     kubectl port-forward service/thrive-monitoring-grafana 8080:80 -n monitoring

     # Retrieve admin password (copy the output)
     # Username: admin
     kubectl get secret thrive-monitoring-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 --decode ; echo

     # Access http://localhost:8080 - login with user 'admin' and the retrieved password
     ```
6. Cleanup resources after evaluation (**highly recommended**):
   - *Expected Outcome:* AWS resources safely removed to avoid unnecessary charges.
   ```bash
   terraform destroy -auto-approve
   ```

For detailed commands, prerequisites, and troubleshooting, refer to [README.md](README.md).

---

## 🛠️ Implementation & Extras:

- **[Project Plan →](0-project-plan.md)** _Detailed project execution strategy and planning._
- **[Architecture Decision Records (ADRs) →](docs/ADRs/)** _Detailed rationale behind infrastructure and CI/CD choices._
- TLS and secret integrations documented as future enhancements (stubbed clearly in YAML manifests).

---

Thanks for your evaluation time and effort!