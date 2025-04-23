# 🔗 Requirements-to-Implications Matrix

This matrix outlines the architectural and tooling implications of each requirement — both explicit and implied. It surfaces dependencies, strategic trade-offs, and potential blockers.

| Requirement                                    | Implications                                                             |
|------------------------------------------------|--------------------------------------------------------------------------|
| Terraform for provisioning                     | Locks in IaC stack; requires HCL familiarity + validation discipline     |
| AWS usage + new account                        | EKS incurs cost → credit workaround needed; fresh IAM setup required     |
| VPC                                            | Requires subnet/IP planning and Terraform module orchestration           |
| Container orchestration                        | Pushes toward EKS over EC2/Docker due to realism & best-practices bias   |
| Load balancer                                  | Requires ALB/ELB or K8s Ingress + Service + annotations                  |
| Auto-scaling                                   | EKS node group configuration, cluster autoscaler optional                |
| Node.js app                                    | Must write or adapt Dockerfile + K8s deployment YAML                     |
| CI/CD pipeline                                 | GitHub Actions + kubeconfig/secrets + conditional staging logic          |
| Metrics exposure                               | Adds Prometheus scraping annotations or custom exporters                 |
| Alerting                                       | Requires Alertmanager + config, or external service + webhook            |
| TLS                                            | Requires cert-manager, Issuer config, DNS or HTTP challenge              |
| Canary/Blue-green                              | Argo Rollouts or kube-native pattern; Argo Rollouts selected             |
| Secrets integration                            | Requires AWS Secrets Manager + Kubernetes operator + IAM role setup      |
| Health checks                                  | Adds probes to K8s spec + rollouts AnalysisTemplates (if Argo used)      |
| Replication instructions                       | Forces modular, reproducible code; human-proof CLI flow                  |
| Diagrams + trade-off notes                     | Requires just-in-time documentation + tight architecture rationale       |
