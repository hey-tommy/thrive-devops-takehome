# ADR-004: Use of Terraform Modules

**Context:**

The project requires provisioning significant AWS infrastructure, including a VPC, networking components (subnets, route tables, security groups), an EKS cluster, ECR repository, and associated IAM roles and policies using Terraform. Writing all these resources manually (`resource` blocks) provides granular control but is time-consuming and error-prone, requiring deep knowledge of each service's intricacies.

**Decision:**

Leverage well-established, community-vetted **Terraform modules** from the public Terraform Registry for complex infrastructure components, specifically:

1.  `terraform-aws-modules/vpc/aws`: For creating the VPC, subnets, route tables, internet gateway, and security groups.
2.  `terraform-aws-modules/eks/aws`: For provisioning the EKS control plane, managed node groups, and associated IAM roles/policies.

Pin specific versions of these modules in the Terraform configuration (`main.tf`) to ensure repeatable deployments and avoid unexpected changes from upstream module updates.

Define other resources, like the ECR repository and specific IAM roles (e.g., for GitHub Actions OIDC), directly using `resource` blocks when they are simpler or require specific customization not easily abstracted by a generic module.

**Consequences:**

*   **Positive:**
    *   **Accelerated Development:** Significantly reduced the time required to provision complex infrastructure like VPCs and EKS clusters.
    *   **Best Practices:** Leveraged community knowledge and AWS best practices embedded within the modules (e.g., tagging, security group configurations, IAM policies).
    *   **Maintainability:** Easier to manage and update infrastructure by adjusting module inputs and versions rather than maintaining large numbers of individual resource blocks.
    *   **Readability:** Abstracted low-level details, making the root Terraform configuration (`infra/terraform/`) more focused on the overall architecture.
*   **Negative:**
    *   **Abstraction Layer:** Less direct control over every single resource attribute compared to manual definition. Customizations might require deeper understanding of module internals or using overrides.
    *   **Dependency:** Reliance on external module maintainers for updates, bug fixes, and compatibility with new AWS features or Terraform provider versions.
    *   **Learning Curve:** Understanding module inputs, outputs, and behavior is necessary for effective use.
