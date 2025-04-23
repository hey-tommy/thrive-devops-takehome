# ADR-003: GitHub Actions for CI/CD

**Status:** Accepted

**Context:**

This project requires an automated Continuous Integration and Continuous Deployment (CI/CD) pipeline to build the application's Docker image, push it to a container registry (AWS ECR), and deploy it to the Kubernetes cluster (AWS EKS). Key requirements include secure authentication to AWS, ease of integration with the source code repository, and efficiency for a time-constrained assignment. The repository is hosted on GitHub.

Alternatives considered included GitLab CI, Jenkins, CircleCI, and AWS CodePipeline.

**Decision:**

We chose **GitHub Actions** as the CI/CD platform for this project.

The decision was based on the following factors:

1.  **Native Integration:** GitHub Actions is tightly integrated with GitHub repositories, providing a seamless experience for triggering workflows based on code pushes, pull requests, etc., directly alongside the source code.
2.  **OIDC Authentication:** GitHub Actions offers robust support for OpenID Connect (OIDC), enabling secure, keyless authentication to AWS services like ECR and EKS. This avoids the need to manage long-lived AWS access keys as GitHub secrets.
3.  **Marketplace Actions:** A rich marketplace of pre-built actions (e.g., `actions/checkout`, `aws-actions/configure-aws-credentials`, `docker/build-push-action`) significantly simplifies the creation of complex workflows, reducing boilerplate code.
4.  **Ease of Use & Familiarity:** For developers familiar with GitHub, the learning curve is relatively gentle. The YAML-based workflow definition is straightforward and version-controlled within the repository.
5.  **Cost-Effectiveness:** GitHub Actions provides a generous free tier for public repositories, sufficient for the needs of this assignment.

**Consequences:**

*   **Positive:**
    *   CI/CD configuration (`cicd.yaml`) is version-controlled alongside the application and infrastructure code.
    *   Simplified secrets management through OIDC.
    *   Leverages existing GitHub ecosystem knowledge.
    *   Clear visibility of build and deployment status directly within the GitHub UI.
    *   Manual triggers via `workflow_dispatch` allow for on-demand deployments.
*   **Negative:**
    *   Dependency on the GitHub platform's availability.
    *   Debugging complex workflow issues can sometimes be less intuitive than debugging locally.
    *   Potential vendor lock-in (though the core concepts are transferable).
