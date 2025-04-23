# ⚠️ Potential Contradictions & Resolution Notes

This document logs inconsistencies or potential contradictions in the assignment, and documents how they are interpreted or mitigated.

---

### 🔸 Potential Contradiction #1: Multi-Platform vs AWS-Only Mandate

**Text Evidence:**
- Early instructions suggest EKS/GKE/AKS or Docker+EC2
- Final instructions require a **brand new AWS account**

**Interpretation:**
- The mention of GKE/AKS is likely leftover boilerplate
- The AWS requirement is stronger and repeated explicitly

**Resolution:**
- AWS is selected as the exclusive platform
- No effort will be made to support other providers

---

### 🔸 Potential Contradiction #2: Use of EKS vs. Free-Tier Only

**Text Evidence:**
- Instructions say to avoid “any additional billing”
- Instructions explicitly list EKS as a valid choice
- But EKS is **not free-tier eligible**

**Interpretation:**
- Intent is to **minimize cost**, not restrict to free-tier only
- EKS is offered as a valid choice

**Resolution:**
- Applied for AWS **Rapid Ramp credits** to cover EKS billing
- Billing risk is acknowledged and mitigated
- Architecture notes will include a fallback to Docker/EC2 if cost becomes prohibitive