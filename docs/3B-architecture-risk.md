## ⚠️ Feasibility Risk Log & Mitigation Plan

This log identifies the top risks associated with the selected architecture and delivery plan. Each item includes its impact area, potential failure mode, and a clearly defined mitigation or fallback strategy. All risks are framed in context of the limited time and AWS account constraints.

---

### 🟥 Risk 1: EKS Provisioning Delay or Failure

**Impact:** Infrastructure  
**Risk:** EKS provisioning fails due to IAM misconfiguration, region quota, or Terraform bugs  
**Mitigation:**
- Validate EKS config in isolation before full CI/CD setup
- Fallback path: switch to `EC2 + Docker Compose` (documented in README)
- Preserve manifests for redeploying app stack on alternate platform if needed

---

### 🟧 Risk 2: Argo Rollouts Controller Misconfiguration

**Impact:** Deployment strategy  
**Risk:** Argo Rollouts controller fails to apply rollout logic correctly, breaking progressive delivery  
**Mitigation:**
- Use CRD installation + Helm install instructions directly from Argo docs
- Stub `Rollout` manifest with a static deployment as fallback
- Document what the rollout behavior *would have been* using comments and demo logs

---

### 🟨 Risk 3: External Secrets Fails to Sync

**Impact:** Secrets management  
**Risk:** External Secrets Operator fails to sync with AWS Secrets Manager due to IRSA misconfig or secret format  
**Mitigation:**
- Test IRSA independently with a known read-only secret
- Fallback: replace ExternalSecret with `k8s Secret` and document intent
- Pre-generate safe static secret (`example-token`) for demo use

---

### 🟦 Risk 4: TLS Cert Issuance Fails

**Impact:** HTTPS setup  
**Risk:** cert-manager setup fails due to DNS propagation or misconfigured Issuer  
**Mitigation:**
- Stub cert-manager manifests with comment blocks for full path
- Fallback to Nginx with self-signed cert or plaintext HTTP for demo
- Document clear TLS intention and link to cert-manager docs

---

### 🟩 Risk 5: Monitoring Stack Complexity Overruns

**Impact:** Observability  
**Risk:** Prometheus + Grafana deployment is time-consuming, high surface area  
**Mitigation:**
- Prioritize minimal `kube-prometheus-stack` values file
- Use pre-baked dashboards if setup time exceeds estimate
- Stub alert rules with placeholder `yaml` and document planned output

---
