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
- **Secrets Management**: Secrets synced from **AWS Secrets Manager** using the **Kubernetes External Secrets** operator via **IRSA**.

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

### 2. Deploy Application (via GitHub Actions)

Commit and push changes to the `main` branch to trigger the GitHub Actions workflow (`.github/workflows/deploy.yaml`). This workflow will:

1.  Build the multi-arch Docker image for the Node.js application (`app/`).
2.  Push the image to AWS ECR.
3.  Update the Kubernetes manifests (`k8s/`) with the new image tag.
4.  Apply the base manifests (`k8s/base/`).
5.  Apply the Argo Rollouts manifests (`k8s/rollouts/`) to initiate a canary deployment.

### 3. Monitor the Rollout (Optional but Recommended)

```bash
kubectl argo rollouts get rollout thrive-devops-app-rollout -n default --watch
```

Wait for the rollout status to become `Healthy`.

### Accessing the Deployed Application

Once the infrastructure is provisioned and the application is successfully deployed via GitHub Actions or manual `kubectl apply`:

1.  **Get the Load Balancer Hostname:** The application is exposed externally using a Kubernetes Service of type `LoadBalancer`. Find its assigned DNS hostname:
    ```bash
    kubectl get svc thrive-devops-app-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    ```
2.  **Access in Browser:** Copy the hostname output from the previous command and paste it into your browser's address bar. Use `http` (not `https`, as TLS is not currently configured):
    ```
    http://<EXTERNAL-HOSTNAME>
    ```
    You should see the "Hello World!" message from the Node.js application.

### 3. Accessing Monitoring (Grafana)

Once the `kube-prometheus-stack` is deployed (part of the Terraform infrastructure setup), you can access the Grafana dashboard locally:

1.  **Port-Forward:** Run the following command in your terminal:
    ```bash
    kubectl port-forward svc/thrive-monitoring-grafana 3000:80 -n monitoring
    ```
2.  **Access URL:** Open [http://localhost:3000](http://localhost:3000) in your web browser.
3.  **Login:**
    *   **Username:** `admin`
    *   **Password:** `prom-operator` (This is the default, retrieve the current password if needed: `kubectl get secret thrive-monitoring-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 --decode`)

Explore the pre-configured dashboards, adjusting the time range in the top-right corner if needed (e.g., to "Last 1 hour").

---

## 🔄 Replicating the Setup

To replicate this setup on a different AWS account:
1.  **Prerequisites**: Ensure the new account has the necessary tools installed (AWS CLI, Terraform, kubectl, Git) and credentials configured.
2.  **Fork & Clone**: Fork this repository to your own **GitHub** account and clone it locally.
3.  **Update Account-Specific Values**: Modify the following files with the new **AWS** Account ID:
    *   `infra/terraform/main.tf`: Update the `principal_arn` for `aws_eks_access_entry.terraform_admin` and `aws_eks_access_entry.github_actions`.
    *   `.github/workflows/deploy.yaml`: Update the `role-to-assume` ARN with the new account ID.
4.  **Configure GitHub Actions OIDC**: In the *new* **AWS** account, set up an IAM OIDC identity provider for **GitHub Actions** and create the `GitHubActions-ThriveDevOpsRole` IAM role with the necessary trust policy pointing to *your* **GitHub** repository and the required permissions (ECR push/pull, EKS access). Refer to **GitHub** and **AWS** documentation for setting up OIDC.
5.  **Run Terraform**: Navigate to `infra/terraform` and run `terraform init` and `terraform apply` using the credentials for the *new* **AWS** account.
6.  **Create Secrets**: In the *new* **AWS** account's Secrets Manager, create the required secrets (e.g., `thrive-devops/demo-app-secrets`) that the application expects. The Kubernetes External Secrets operator will sync these.
7.  **Configure `kubectl`**: Run `aws eks update-kubeconfig ...` using the Terraform outputs from the new account.
8.  **Push to Trigger CI/CD**: Push a commit to the `main` branch of *your* forked repository to trigger the **GitHub Actions** workflow, which will build and deploy the application to the new EKS cluster.

---

## 🔐 Secrets Management

Secrets are managed centrally in **AWS Secrets Manager** and securely injected into Kubernetes pods using the **Kubernetes External Secrets (KES)** operator.

*   The KES operator is installed via Helm chart (managed by Terraform `helm_release`).
*   An IAM Role for Service Account (IRSA) is configured, granting the KES operator's service account permissions to read secrets from AWS Secrets Manager.
*   A `ClusterSecretStore` resource (`k8s/secrets/secret-store.yaml`) defines how KES connects to AWS Secrets Manager using the IRSA role.
*   `ExternalSecret` resources (e.g., `k8s/secrets/external-secret.yaml`) specify which AWS secrets to sync and what Kubernetes `Secret` objects to create/update.
*   The application deployment (`k8s/base/deployment.yaml`) references the Kubernetes `Secret` created by KES to load secrets as environment variables.

See [ADR 006](docs/ADRs/006-kubernetes-external-secrets.md) for more details on the decision process.

---

## 📊 Monitoring & Alerting

(*Planned*)

This section will be updated with details on accessing **Grafana** dashboards and understanding the configured **Prometheus** alerts once implemented.

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
| Secrets Management    | ✅ Complete   |
| Bonus Features (TLS)  | ⏳ Upcoming   |
| Polish & Docs         | ✍️ Ongoing    |

---

Thanks for reviewing!