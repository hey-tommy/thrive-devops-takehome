## ⏱️ Work Item Breakdown & Degradation Strategy

This document provides a **granular, sequenced breakdown** of work items aligned to the execution plan. Each work unit includes its output, blocking dependencies, and fallback or stub strategy where applicable.

---

### 🟢 Layer 1: Must-Haves (Core Infrastructure & Deployment Path)

These work items must be completed in order — they represent the foundation of the system.

| #   | Work Item                                               | Output / File(s)                                 | Blocking  | Stub / Fallback Plan                                  | Est. Time |
| --- | ------------------------------------------------------- | ------------------------------------------------ | --------- | ----------------------------------------------------- | --------- |
| 0   | Create basic Node.js "Hello World" app                  | `app/server.js`                                  | —         | Minimal stub with console log                         | 5 min     |
| 1   | Create `main.tf` (Terraform root module)                | `infra/terraform/main.tf`                        | —         | —                                                     | 2 min     |
| 2   | Add VPC module (explicit note: covers VPC req)          | `infra/terraform/modules/vpc.tf`                 | 1         | Use AWS default VPC (commented)                       | 10 min    |
| 3   | Add EKS module + node group (explicit: auto-scaling)    | `infra/terraform/modules/eks.tf`                 | 2         | Fallback to EC2 + Docker Compose, stub note in README | 20–30 min |
| 4   | Add IAM roles + IRSA support                            | `infra/terraform/modules/iam.tf`                 | 2         | Use static `accessKey` if time-crunched (unsafe demo) | 10–15 min |
| 5   | Add ECR resource                                        | `infra/terraform/modules/ecr.tf`                 | 1         | Push to Docker Hub instead                            | 5–10 min  |
| 6   | Run `terraform apply`, capture outputs                  | `infra/terraform/outputs.tf`                     | 1–5       | N/A                                                   | 5–10 min  |
| 7   | Update kubeconfig from Terraform output                 | `aws eks update-kubeconfig ...`                  | 3, 6      | —                                                     | 2 min     |
| 8a  | Build Docker image locally                              | `app/Dockerfile`                                 | 0         | —                                                     | 5 min     |
| 8b  | Push image to ECR                                       | ECR repo                                         | 5, 7, 8a  | Push locally + tag manually                           | 5–10 min  |
| 9   | Install Argo Rollouts controller                        | `k8s/rollouts/controller.yaml`                   | 7         | Fallback to standard K8s deployment                   | 5–10 min  |
| 10  | Define base rollout manifest (add K8s probes)           | `k8s/rollouts/app-rollout.yaml`                  | 8b, 9     | Stub rollout steps, use static spec                   | 10 min    |
| 11  | Create base service + ingress (explicit: load balancer) | `k8s/base/service.yaml`, `ingress.yaml`          | 10        | Stub ingress with comment; use `NodePort`             | 10 min    |
| 12  | Implement `/healthz` endpoint in app & K8s probes       | `app/server.js`, `k8s/rollouts/app-rollout.yaml` | 0, 10, 11 | Static response, stub probe config                    | 5–10 min  |
| 13  | Apply rollout + base manifests                          | `kubectl apply -f k8s/`                          | 10–12     | —                                                     | 5–10 min  |

---

### 🔵 Layer 2: Strategic Core (Pipeline, Metrics, Alerting)

Layer 2 builds trust with evaluators by proving deploy automation and production visibility.

| #  | Work Item                                         | Output / File(s)                            | Blocking           | Stub / Fallback Plan                                   | Est. Time |
|----|---------------------------------------------------|---------------------------------------------|--------------------|--------------------------------------------------------|-----------|
|14  | Write GitHub Actions build workflow               | `.github/workflows/deploy.yml`              | 8b                 | Build only — manually `kubectl apply`                  | 15–20 min |
|15  | Add EKS deploy step to CI                         | `.github/workflows/deploy.yml`              | 7, 10              | Commented step, fallback to CLI deploy only            | 10–15 min |
|16  | Install Prometheus                                | `monitoring/prometheus-values.yaml`         | 7                  | Documented stub + alert rule placeholder               | 15–20 min |
|17  | Configure serviceMonitor + scrape annotations     | `k8s/base/deployment.yaml`, `servicemonitor.yaml` | 16            | Static config + fake sample scrape                     | 10 min    |
|18  | Add Alertmanager config (Slack webhook)           | `monitoring/alertmanager/`                  | 16, 17             | Static rule only, webhook URL redacted                 | 5–10 min  |
|19  | Add optional Grafana dashboard JSON               | `monitoring/grafana-dashboards/app.json`    | 16                 | Link to online demo dashboards in `README.md`          | 10–15 min |
|20  | Update documentation: architecture, metrics, deploy instructions | `README.md`, `EVALUATOR.md` | 13–19 | Add placeholder sections, update as features land | 10–20 min |
---

### 🟡 Layer 3: High-Signal Extras (TLS, Secrets, Rollback Logic)

| #  | Work Item                                         | Output / File(s)                            | Blocking           | Stub / Fallback Plan                                   | Est. Time |
|----|---------------------------------------------------|---------------------------------------------|--------------------|--------------------------------------------------------|-----------|
|21  | Install cert-manager CRDs + Issuer               | `k8s/base/cert-manager-issuer.yaml`         | 11                 | Commented TLS block + redirect HTTP                    | 10–15 min |
|22  | Annotate ingress for TLS                         | `k8s/base/ingress.yaml`                     | 11, 21             | Stub with `# TODO: Enable TLS via cert-manager`        | 5 min     |
|23  | Add External Secrets CR                          | `k8s/secrets/external-secret.yaml`          | 4, 7               | Manual `Secret` placeholder                            | 10–15 min |
|24  | Define AnalysisTemplate for rollback             | `k8s/rollouts/analysis-template.yaml`       | 16, 10             | Mock output log, disabled `analysis:` section          | 10–15 min |
|25  | Final documentation polish (diagrams, replication guide, unbuilt section) | `README.md`, `EVALUATOR.md`, `docs/diagrams/` | 20, 24 | Add stubs, placeholder images, clear "Unbuilt but Accounted For" section | 10–15 min |
---

### 🔴 Optional Flair (If < 90 min Remain)

| # | Work Item                                         | Output / File(s)                            | Blocking           | Notes                                                   | Est. Time |
|---|---------------------------------------------------|---------------------------------------------|--------------------|----------------------------------------------------------|-----------|
|26 | Argo Experiment YAML (A/B style rollout)          | `k8s/rollouts/experiment.yaml`              | 9, 10              | Only if core rollout logic fully stable                  | 20–30 min |
|27 | Argo UI screenshot capture                        | `docs/diagrams/argo-ui.png`                 | 13, 10             | Embed in `README.md`, link with caption                  | 5–10 min  |
|28 | Record Loom demo                                  | `README.md` → Demo section                  | 13                 | Bonus signal; script can be informal                     | 10–15 min |
|29 | Add CI novelty (e.g., chat comment bot)           | `.github/workflows/fun.yml` (optional)      | 14                 | Only if extremely ahead of schedule                      | 10–15 min |
---

### Marking & Documentation Strategy

If a task is skipped or stubbed:

- Leave an explicit `# TODO:` or `# Fallback:` comment in relevant file
- Add a section to `README.md` or `EVALUATOR.md` titled **Unbuilt but Accounted For**
- Include placeholder YAML or empty files with annotations (e.g., `analysis-template.stub.yaml`)
- All placeholders must look **intentional** — no dead ends

---
