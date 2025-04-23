## 🧮 Annotated Architecture Tree w/ Dependencies

This annotated version of the architecture decision tree expands each major decision point with trade-offs, dependency chains, constraints, and signals. Its purpose is to inform final path selection in Step 3A.

---

### 📦 Core Infrastructure

```
Infrastructure Provisioning
└── Terraform → AWS Provider
    ├── VPC
    │   🔗 Requires subnet IP planning, NAT gateway setup if public + private
    │   ⚠️ NAT adds cost; avoid unless using private nodes
    │   📈 Signals understanding of cloud networking
    │   🛑 Common failure: subnet/IP overlap, no public route table
    │
    ├── Compute Platform
    │   ├── EKS
    │   │   🔗 Requires IAM roles, node groups, kubeconfig setup
    │   │   ⚠️ Not free-tier, requires credit mitigation
    │   │   📈 Aligns with real-world production infra
    │   │   🛑 Slow to provision (~15min+), debug loops risky
    │   │
    │   └── EC2 + Docker
    │       🔗 Easier IAM, cheaper; no cluster config needed
    │       ⚠️ Perceived as less modern
    │       📈 Good fallback if time/budget tight
    │       🛑 Fragile for autoscaling, not future-proof
    │
    ├── Load Balancer
    │   ├── ALB
    │   │   🔗 Requires K8s annotations + controller
    │   │   ⚠️ Only works properly with EKS
    │   │   📈 Seen as canonical for AWS K8s
    │   │
    │   └── Ingress + Service
    │       🔗 Simpler, can use Nginx ingress controller
    │       📈 More portable
    │       🛑 If improperly configured, won’t route traffic
    │
    └── Auto-Scaling
        ├── EKS Node Group
        │   🔗 Requires managed node group configs
        │   📈 Signals K8s fluency
        │
        └── EC2 ASG
            🔗 Less infra overhead, but must be manually linked to AMIs
            🛑 Requires own orchestration logic

```

---

### 🚀 Application Build & Delivery

```
App Build & Containerization
└── Docker
    🔗 Must be compatible with EKS or EC2 runtime
    ⚠️ Alpine can introduce SSL/libc issues in Node apps
    📈 Multi-stage Dockerfile = professional touch

CI/CD Tooling
└── GitHub Actions
    🔗 Must securely inject AWS creds and KUBECONFIG
    ⚠️ K8s deploy step must wait for cluster readiness
    📈 Clear alignment with assignment expectations
    🛑 YAML errors can silently break builds
```

---

### 🧭 Deployment to Cluster

```
Deployment Strategy
├── Standard Deployment
│   📈 Good fallback, low risk
│
├── Argo Rollouts (Canary)
│   🔗 Requires CRDs, controller, health metrics
│   ⚠️ High complexity; adds risk
│   📈 Major signal of maturity + bonus box checked
│
└── Blue-Green
    🔗 Requires manual service-switch orchestration
    🛑 Hard to test without real traffic flow
    📈 Low signal compared to Argo
```

---

### 🔒 Secrets Management

```
Secrets Backend
├── AWS Secrets Manager
│   🔗 Requires External Secrets Operator + IRSA
│   ⚠️ Hard to test without real secrets
│   📈 High alignment with real MLOps patterns
│
└── K8s Secrets (Manual)
    🔗 Easier to stub
    📈 Acceptable fallback
    🛑 Static values get flagged in reviews
```

---

### 📈 Monitoring & Observability

```
Metrics Stack
├── Prometheus (kube-prometheus-stack)
│   🔗 Requires Helm or full YAML manifests
│   ⚠️ Configuration-heavy; many moving parts
│   📈 Major signal of observability maturity
│
└── CloudWatch fallback
    🔗 Easier to wire, but weaker signal
    📈 Acceptable stub if Prometheus fails

Alerting
├── Alertmanager → Slack
│   📈 High ROI
│
└── Email fallback
    📈 Acceptable, lower fidelity
```

---

### 🔐 TLS

```
TLS Termination
├── cert-manager
│   🔗 Requires Issuer, Ingress annotations, DNS config
│   ⚠️ Easy to misconfigure
│   📈 Bonus item; high polish signal
│
└── Reverse proxy
    🔗 Can use Nginx or Traefik
    🛑 Manual certs feel hacked
```

---

### 🩺 Health Checks

```
Health Check Integration
├── K8s liveness + readiness probes
│   📈 Must-have baseline
│
└── Argo Rollouts AnalysisTemplate
    🔗 Requires Prometheus integration
    ⚠️ Only worth it if metrics + Argo are ready
    📈 Very high signal if working
```

---
