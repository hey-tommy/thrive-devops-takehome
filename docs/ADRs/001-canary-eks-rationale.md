# ADR-001: Canary + EKS (Argo Rollouts)

## Decision Summary

Selected architecture path: **Canary + EKS using Argo Rollouts**

This was not the simplest option — it was chosen to demonstrate progressive delivery maturity, future extensibility, and Terraform orchestration capability.

---

## Why Not Blue-Green?

- **Limited future extensibility**: Blue-Green deployment is binary and rigid. It lacks phased rollout semantics and does not support nuanced traffic control.
- **Poor reusability**: Much of the configuration (e.g., CodeDeploy setup, target group juggling) is non-transferable to Canary or K8s patterns.
- **Low “wow” factor**: Blue-Green is seen as safe but conservative. In a portfolio take-home context, it under-delivers on signaling strength.

---

## Why Not ALB-based Canary?

- **Shallow control**: ALB-weighted routing lacks version awareness, rollback automation, and rollout phases.
- **Non-native**: Traffic percentages are opaque; no way to describe or observe rollout state via declarative tools.
- **Poor A/B extensibility**: A/B testing is possible but awkward, requiring sticky routing hacks and custom metrics logic.
- **Reviewer optics**: While clever, it doesn’t reflect orchestration expertise or MLOps-adjacent tooling.

---

## Why Canary + EKS (Argo Rollouts) Wins

- **Built for progressive delivery**: Native phased rollouts, rollback control, analysis templates, pause/resume steps.
- **Declarative & auditable**: Fully GitOps-compatible via CRDs; changes can be versioned, reviewed, and promoted.
- **Future-proof**: A/B testing paths can be added using Argo Experiments with minimal structural change.
- **Tooling maturity**: Combines Terraform, Helm, Argo, and Prometheus — a toolchain common in MLOps and modern DevOps teams.
- **High-impact demo**: Seeing a rollout visibly progress in Argo UI or CLI creates an immediate impression of mastery.

---

## Comparison Table

| Pattern                | Terraform Complexity | Reuse for A/B | Reviewer "Wow" | Future-Ready |
|------------------------|----------------------|---------------|----------------|--------------|
| Blue-Green (ECS/ALB)   | Medium                | ❌ Poor        | ★★☆☆☆           | ❌ No         |
| Canary (ALB-only)      | Low–Medium           | ⚠️ Partial     | ★★★☆☆           | ⚠️ Partial    |
| **Canary (EKS + Argo)** | **High**             | ✅ Excellent   | ★★★★★           | ✅ Excellent  |

---

## Final Note

This decision prioritizes **senior-level system design and forward extensibility**. It trades raw implementation speed for clarity, narrative strength, and orchestration depth — producing not just a deliverable, but a story.

---
