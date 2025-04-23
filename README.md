# 🚀 Thrive DevOps Take-Home Assignment

This repository contains the submission for the DevOps/MLOps take-home assignment.

---

## 📐 Architecture Overview

The core architecture consists of:

- **Cloud Platform**: **AWS**
  - **VPC**: Custom VPC created using the `terraform-aws-modules/vpc/aws` module.
  - **Container Orchestration**: **Amazon EKS** provisioned via the `terraform-aws-modules/eks/aws` module.
  - **Container Registry**: **Amazon ECR** for storing Docker images.
  - **Identity & Access**: **AWS IAM** for service roles and OIDC connection for **GitHub Actions**.
- **Infrastructure-as-Code (IaC)**: **Terraform** manages all cloud resources.
- **Application**: A simple Node.js "hello-world" application containerized using **Docker**.
- **Deployment Strategy**: Canary deployments orchestrated by **Argo Rollouts** on **Kubernetes**.
- **CI/CD**: **GitHub Actions** pipeline automates Docker image builds (multi-arch) and **Kubernetes** manifest application.
- **Monitoring**: (*Planned*) **Prometheus** and **Grafana** stack to be deployed via **Helm**/**Kubernetes** manifests.
- **Secrets Management**: (*Planned*) **AWS Secrets Manager** integration using the **Kubernetes External Secrets** operator.

Diagrams visualizing the infrastructure and deployment flow can be found in the `docs/diagrams/` directory (`system_architecture.png`).

---

## 🛠️ Prerequisites

Before deploying, ensure you have the following:

1.  **AWS Account**: A configured AWS account.
2.  **AWS Credentials**: Configured AWS CLI credentials (e.g., via `~/.aws/credentials` or environment variables) with sufficient permissions to create VPC, EKS, ECR, IAM resources.
3.  **Terraform**: Terraform CLI installed (`>= 1.0`).
4.  **kubectl**: Kubectl CLI installed.
5.  **Docker**: Docker installed (optional, for local image builds/tests).
6.  **Git**: Git CLI installed.

---

## 📦 How to Deploy

Deployment involves two main phases: infrastructure provisioning via **Terraform** and application deployment via the **GitHub Actions** CI/CD pipeline.

### 1. Provision Infrastructure

These steps only need to be run once to set up the base infrastructure (VPC, EKS Cluster, ECR Repo, IAM Roles/Policies).

```bash
# Clone the repository
git clone https://github.com/your-username/thrive-devops-takehome.git # Replace with your fork/clone URL
cd thrive-devops-takehome

# Set your AWS Profile (if not using default or environment variables)
export AWS_PROFILE=your-profile-name

# Navigate to the Terraform directory
cd infra/terraform

# Initialize Terraform (downloads providers)
terraform init

# Plan the infrastructure changes
terraform plan

# Apply the infrastructure changes (requires confirmation)
terraform apply

# Configure kubectl to connect to the new EKS cluster
# (Uses output from terraform apply)
aws eks update-kubeconfig --region $(terraform output -raw aws_region) --name $(terraform output -raw eks_cluster_name)

# Verify kubectl connection
kubectl get nodes
```

### 2. Deploy Application (CI/CD)

The application deployment is automated via the **GitHub Actions** workflow defined in `.github/workflows/cicd.yaml`.

1.  **Commit & Push**: Commit any changes to the application (`app/`), **Dockerfile**, or **Kubernetes** manifests (`k8s/`).
2.  **Trigger**: Push the commit(s) to the `main` branch of your **GitHub** repository.
3.  **Workflow Execution**: The **GitHub Actions** workflow will automatically:
    *   Check out the code.
    *   Configure **AWS** credentials using OIDC.
    *   Log in to **Amazon ECR**.
    *   Build a multi-platform **Docker** image (`linux/amd64`, `linux/arm64`).
    *   Push the image to **ECR** tagged with the Git SHA and `latest`.
    *   Update the `k8s/rollouts/app-rollout.yaml` manifest with the new image tag (Git SHA).
    *   Apply the updated manifest to the **EKS** cluster using `kubectl apply`.
    *   **Argo Rollouts** manages the canary deployment process based on the `app-rollout.yaml` strategy.

### 3. Accessing the Application

Once the rollout is complete, the application is exposed via a **Kubernetes** Service of type `LoadBalancer`.

```bash
# Get the Load Balancer URL
kubectl get service thrive-devops-app-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Note: It may take a few minutes for the Load Balancer to provision and the DNS to propagate.
# Access the URL in your browser.
```

---

## 🔄 Replication on a New AWS Account

To deploy this project on a *different* **AWS** account, follow these steps:

1.  **Prerequisites**: Ensure the new account has the necessary tools installed (AWS CLI, Terraform, kubectl, Git) and credentials configured.
2.  **Fork & Clone**: Fork this repository to your own **GitHub** account and clone it locally.
3.  **Update Account-Specific Values**: Modify the following files with the new **AWS** Account ID:
    *   `infra/terraform/main.tf`: Update the `principal_arn` for `aws_eks_access_entry.terraform_admin` and `aws_eks_access_entry.github_actions`.
    *   `.github/workflows/cicd.yaml`: Update the `role-to-assume` ARN with the new account ID.
4.  **Configure GitHub Actions OIDC**: In the *new* **AWS** account, set up an IAM OIDC identity provider for **GitHub Actions** and create the `GitHubActions-ThriveDevOpsRole` IAM role with the necessary trust policy pointing to *your* **GitHub** repository and the required permissions (ECR push/pull, EKS access). Refer to **GitHub** and **AWS** documentation for setting up OIDC.
5.  **Run Terraform**: Navigate to `infra/terraform` and run `terraform init` and `terraform apply` using the credentials for the *new* **AWS** account.
6.  **Configure `kubectl`**: Run `aws eks update-kubeconfig ...` using the Terraform outputs from the new account.
7.  **Push to Trigger CI/CD**: Push a commit to the `main` branch of *your* forked repository to trigger the **GitHub Actions** workflow, which will build and deploy the application to the new EKS cluster.

---

## 📊 Monitoring & Alerting

(*Planned*)

This section will be updated with details on accessing **Grafana** dashboards and understanding the configured **Prometheus** alerts once implemented.

---

## 🔐 Secrets Management

(*Planned*)

Secrets management using **AWS Secrets Manager** and the **Kubernetes External Secrets** operator is planned but not yet implemented. Configuration details will be added here upon completion.

---

## 📝 Design Decisions & Trade-offs

Key decisions include:

-   **EKS over self-managed Kubernetes**: Chosen for reduced operational overhead, leveraging AWS managed control plane.
-   **Argo Rollouts**: Selected for enabling advanced deployment strategies like canary releases with automated analysis (planned), improving deployment safety over standard Kubernetes Deployments.
-   **GitHub Actions**: Utilized for its tight integration with GitHub repositories and native OIDC support for secure AWS authentication.
-   **Terraform Modules**: Leveraged community modules (`terraform-aws-modules`) for VPC and EKS to accelerate provisioning and adhere to best practices, trading off some granular control for speed and reliability.
-   **Multi-Arch Docker Builds**: Implemented (`linux/amd64`, `linux/arm64`) to ensure compatibility with diverse EKS node architectures (e.g., Graviton instances) after encountering initial `ErrImagePull` issues.

Further decisions and trade-offs will be documented in `docs/ADRs/`.

---

## ✅ Status

| Layer                 | State         |
| --------------------- | ------------- |
| Core Infrastructure   | ✅ Complete   |
| CI/CD Pipeline        | ✅ Complete   |
| Monitoring + Alerts   | ⏳ Upcoming   |
| Secrets Management    | ⏳ Upcoming   |
| Bonus Features (TLS)  | ⏳ Upcoming   |
| Polish & Docs         | ✍️ Ongoing    |

---

Thanks for reviewing!