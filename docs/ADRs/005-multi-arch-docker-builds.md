# ADR-005: Multi-Architecture Docker Builds

**Context:**

The development environment (likely macOS on Apple Silicon - arm64) differs from the target deployment environment (AWS EKS worker nodes using EC2 instances, potentially amd64 or arm64, but initially amd64 in this project). Building a Docker image solely for the developer's architecture (arm64) can lead to runtime failures (`ErrImagePull` or `exec format error`) when attempting to run the container on a different architecture (amd64).

During initial deployment attempts, pods running on the amd64 EKS nodes failed to start due to `ErrImagePull` errors, specifically `no match for platform in manifest`, because the pushed Docker image only contained an arm64 variant.

**Decision:**

Implement **multi-architecture Docker builds** using `docker buildx` within the GitHub Actions workflow.

Specifically, configure the `docker/build-push-action` with `platforms: linux/amd64,linux/arm64`. This instructs Docker Buildx to build image variants for both common Linux architectures and push them together as a single manifest list to ECR.

When Kubernetes (via the container runtime) pulls the image (`<repo>:<tag>`), it automatically selects the image variant matching the node's architecture from the manifest list.

**Consequences:**

*   **Positive:**
    *   **Compatibility:** Ensures the application container image can run correctly on both amd64 and arm64 EKS worker nodes without modification.
    *   **Flexibility:** Allows the EKS cluster to potentially use mixed instance types or change instance types in the future without requiring image rebuilds for a specific architecture.
    *   **Resolved Runtime Errors:** Directly addressed the `ErrImagePull` issues encountered previously.
*   **Negative:**
    *   **Increased Build Time:** Building for multiple platforms takes longer than building for a single platform within the CI/CD pipeline.
    *   **Larger Image Storage (Registry):** The registry stores layers for both architectures, potentially increasing ECR storage costs slightly (though likely negligible for this small application).
    *   **Buildx Requirement:** Requires `docker buildx` to be available and configured in the build environment (handled by `docker/setup-buildx-action` in GitHub Actions).
