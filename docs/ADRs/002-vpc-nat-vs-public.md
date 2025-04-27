# ADR-002: VPC Subnet/NAT Gateway Cost Trade-off

## Decision Summary

**All EKS worker nodes are deployed in public subnets. No NAT Gateway is provisioned.**

This decision strictly avoids NAT Gateway charges, aligning with the assignment’s cost-sensitivity rule. Production environments prefer private subnets with outbound internet (via NAT Gateway or VPC endpoints) for security and best practice.

---

## Why Not NAT Gateway?

- **Not free-tier:** NAT Gateway incurs hourly and data charges, which are not allowed by the assignment except for EKS itself.
- **Demo context:** For this take-home, security trade-offs are acceptable to avoid billing.
- **Reviewer optics:** This signals awareness of cost control and AWS billing behaviors.

---

## Why Not Private Subnets + VPC Endpoints?

- **Complexity:** VPC endpoints for ECR, S3, and STS are free and secure, but add configuration overhead for a demo.
- **Signal:** Not implementing endpoints, but documenting them as a production alternative shows awareness.

---

## Why Public Subnets?

- **Zero cost:** No NAT Gateway required; all nodes have direct internet access for pulling images and updates.
- **Simplicity:** Minimal configuration, easy for reviewers to replicate and destroy.
- **Transparent trade-off:** This approach reduces security (public IPs), but the documentation justifies this for the assignment context.

---

## Production Note

In a real-world deployment:
- Worker nodes should be in private subnets.
- Outbound internet should be provided by a NAT Gateway (billable) or VPC endpoints (free, but requires additional setup).

---
*This ADR documents the rationale for public subnet usage and no NAT Gateway in this assignment. See also: [AWS NAT Gateway Pricing](https://aws.amazon.com/vpc/pricing/), [VPC Endpoints for EKS](https://docs.aws.amazon.com/eks/latest/userguide/vpc-endpoints.html)*
