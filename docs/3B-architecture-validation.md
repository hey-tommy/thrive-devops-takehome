## 📋 Architecture–Requirements Validation Table

This table verifies that each requirement from the checklist is addressed by the chosen architecture. Status values: **Covered**, **Partial**, **Deferred**.

| Requirement                                              | Status     | Notes                                                                                      |
|----------------------------------------------------------|------------|--------------------------------------------------------------------------------------------|
| Terraform for provisioning                               | Covered    | Modularized HCL under `infra/terraform/`                                                   |
| AWS (new account)                                        | Covered    | Fresh account created; Rapid Ramp credits requested                                        |
| VPC                                                      | Covered    | Subnets, route tables, IGW, NAT gateway configured                                         |
| Container orchestration (EKS)                            | Covered    | EKS cluster via Terraform; managed node groups                                            |
| Load balancer (ALB via K8s Service)                      | Covered    | ALB controller + Service annotations                                                       |
| Auto-scaling (EKS Managed Node Groups)                   | Covered    | Node group autoscaling configuration                                                       |
| Node.js app deployment                                   | Covered    | `app/` folder with Dockerfile and source                                                   |
| Docker containerization                                  | Covered    | Multi-stage Dockerfile                                                                   |
| Kubernetes deployment                                    | Covered    | Manifests under `k8s/base/`                                                               |
| CI/CD pipeline (build → push → deploy)                   | Covered    | GitHub Actions workflows in `.github/workflows/`                                           |
| Build Docker image                                       | Covered    | Action step uses `docker build`                                                           |
| Push to registry (ECR)                                   | Covered    | Action step uses `aws ecr` commands                                                        |
| Deploy to cluster                                        | Covered    | CI step runs `kubectl apply` and Argo Rollouts CLI                                         |
| Metrics exposure (CPU, memory, req/sec)                  | Covered    | Prometheus scraping configured via annotations                                             |
| Alerting (Slack webhook)                                 | Covered    | Alertmanager rules → Slack webhook                                                        |
| HTTPS/TLS (cert-manager + Let’s Encrypt)                 | Partial    | cert-manager resources planned; DNS/Issuer in config; stub fallback documented             |
| Canary deployments (Argo Rollouts)                       | Covered    | CRDs and Rollout manifests under `k8s/rollouts/`                                          |
| Secrets management (AWS Secrets Manager + ExternalSecrets)| Covered    | ExternalSecrets CR under `k8s/secrets/`; IRSA configured                                    |
| Health checks (K8s probes + Argo AnalysisTemplate)       | Partial    | Liveness/readiness probes implemented; AnalysisTemplate stub planned                       |
| Replication instructions                                 | Covered    | Detailed in `README.md` under “Replication” section                                        |
| Diagrams & trade-off notes                               | Covered    | ADR in `docs/ADRs/`; diagrams in `docs/diagrams/`                                          |
