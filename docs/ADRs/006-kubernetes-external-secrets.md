# ADR 006: Kubernetes Secrets Management with External Secrets Operator

**Date:** 2025-04-23

**Status:** Accepted

## Context

The application requires access to sensitive information (e.g., API keys, database credentials) stored securely outside the Kubernetes cluster. Hardcoding secrets in configuration files or Kubernetes manifests is insecure and inflexible. A mechanism is needed to inject secrets from a trusted external source (AWS Secrets Manager) into Kubernetes pods securely.

## Decision Drivers

*   **Security:** Avoid storing plaintext secrets in Git or container images.
*   **Centralization:** Manage secrets centrally in AWS Secrets Manager.
*   **Automation:** Automatically sync secrets into Kubernetes.
*   **Integration:** Leverage native Kubernetes concepts (Secrets) and AWS services (Secrets Manager, IAM).
*   **Least Privilege:** Use IAM Roles for Service Accounts (IRSA) for fine-grained access control.

## Considered Options

1.  **Kubernetes External Secrets (KES) Operator:** Syncs secrets from external stores (like AWS Secrets Manager) into native Kubernetes `Secret` objects.
2.  **AWS Secrets & Configuration Provider (ASCP):** Mounts secrets directly into pods as volumes using a CSI driver (requires modifying application code or entrypoint scripts to read from files).
3.  **HashiCorp Vault with Agent Injector:** Powerful, but adds complexity with Vault deployment and management.
4.  **Manual Secret Creation:** Manually create Kubernetes `Secret` objects from values in AWS Secrets Manager (error-prone, lacks automation).

## Decision

We chose to implement the **Kubernetes External Secrets (KES) Operator** integrated with **AWS Secrets Manager** using **IAM Roles for Service Accounts (IRSA)**.

## Rationale

*   **Native K8s Integration:** KES creates standard Kubernetes `Secret` objects, which applications can consume easily via environment variables or volumes without modification.
*   **Simplicity:** KES offers a focused solution for secret synchronization compared to the broader scope (and complexity) of Vault.
*   **Automation:** KES automatically polls AWS Secrets Manager and updates Kubernetes `Secret` objects when the source changes.
*   **Security:** IRSA provides secure, temporary credentials directly to the KES operator pod, adhering to the principle of least privilege.
*   **Alignment with Stack:** Leverages existing AWS infrastructure (Secrets Manager, IAM) and Kubernetes.
*   **Lower Overhead than ASCP:** While ASCP is also a viable option, KES often requires less direct modification to application deployment patterns if environment variable injection is sufficient.

## Consequences

*   **Added Component:** Introduces the KES operator as another component to manage within the Kubernetes cluster.
*   **IAM Configuration:** Requires careful configuration of IAM roles and policies for IRSA.
*   **Sync Latency:** There's a small delay (controlled by `refreshInterval`) between a secret update in AWS Secrets Manager and its reflection in Kubernetes.
*   **Dependency:** The application's ability to retrieve secrets depends on the health of the KES operator and its connection to AWS.
