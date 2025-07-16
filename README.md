# Reusable CI/CD Framework for Cloud-Native Applications

![GitLab Pipeline Status](https://gitlab.com/YOUR_GROUP/YOUR_PROJECT/badges/main/pipeline.svg)

This project provides a robust, reusable, and security-focused CI/CD framework for containerized applications. It leverages GitLab CI/CD, Docker, Kubernetes, and Trivy to automate the build, test, scan, and deployment lifecycle.

## Features

-   **Reusable CI/CD Templates:** Drastically reduce boilerplate in new projects using GitLab's `include` feature.
-   **Automated Docker Builds:** Efficient and secure multi-stage Docker builds.
-   **Automated Testing:** Integrated test stage to ensure code quality.
-   **Security Scanning:** Vulnerability, secret, and misconfiguration scanning with **Trivy**.
-   **Kubernetes Deployments:** Automated, environment-aware deployments to Kubernetes (Staging & Production).
-   **Environment Promotion:** Clear path from development branches to staging and tagged releases to production.
-   **Local Development Support:** Scripts to run security scans locally before pushing code.

## Project Structure
```
.
├── .gitlab
│   └── ci-templates
│       ├── docker-build.yml
│       ├── k8s-deploy.yml
│       └── trivy-scan.yml
├── .gitlab-ci.yml
├── k8s
│   ├── deployment.yaml
│   └── service.yaml
├── scripts
│   └── scan-local.sh
├── .trivyignore
├── trivy-config.yaml
└── trivy-policy.yaml
```
---

## How It Works: The CI/CD Pipeline

The pipeline is defined in `.gitlab-ci.yml` and broken down into logical stages using templates from the `.gitlab/ci-templates/` directory.

1.  **Build:**
    -   A multi-stage Dockerfile creates a lean, production-ready container image.
    -   The image is tagged with the unique Git commit SHA and pushed to the GitLab Container Registry.
    -   If the commit is on the default branch (`main`), it is also tagged as `latest`.

2.  **Test:**
    -   Runs unit and integration tests using the application's native test runner (e.g., `npm test`).
    -   This stage runs *before* the production image is finalized to ensure code correctness.

3.  **Security Scan:**
    -   Uses **Trivy** to scan the container image for known vulnerabilities (CVEs), IaC misconfigurations, and exposed secrets.
    -   The pipeline will **fail** if any `HIGH` or `CRITICAL` severity vulnerabilities are found.
    -   A full report is generated and integrated directly into the GitLab Security Dashboard.

4.  **Deploy:**
    -   **Staging:** Commits to the `develop` branch are automatically deployed to the `staging` Kubernetes namespace.
    -   **Production:** Git tags (e.g., `v1.0.0`) trigger a **manual** deployment job to the `production` namespace, ensuring a human gate before release.
    -   Deployments use `kubectl` to apply the manifests located in the `k8s/` directory.

---

## Getting Started

### Prerequisites

1.  A Kubernetes cluster with `kubectl` access.
2.  A GitLab project with a GitLab Runner configured to run Docker containers.
3.  Your Kubernetes configuration (`kubeconfig`) available.

### Configuration

1.  **Fork/Clone this Repository:** Use this project as a template for your new service.

2.  **Configure GitLab CI/CD Variables:**
    Navigate to `Settings > CI/CD > Variables` in your GitLab project and add the following:
    -   `KUBE_CONFIG`: The base64-encoded content of your `kubeconfig` file. You can get this by running: `cat ~/.kube/config | base64 -w 0`. **This should be a `File` type variable.**
    -   `YOUR_DOMAIN`: The base domain for your application (e.g., `my-company.com`). Used for ingress rules.

3.  **Customize Kubernetes Manifests:**
    -   Review `k8s/deployment.yaml` and `k8s/service.yaml`. Adjust resource requests/limits, replica counts, and health check paths as needed for your application.
    -   Update the ingress host in `k8s/service.yaml` to use your domain.

4.  **Update Your Application Code:**
    -   Add your application source code to the repository.
    -   Ensure you have a `Dockerfile` (or use the one provided if it's a Node.js app).
    -   Make sure your `package.json` (or equivalent) has a `test` script.
    -   Your application should have a health check endpoint (e.g., `/health`).

---

## Local Development

You can scan your Docker images locally before pushing them to GitLab to get faster feedback.

### Local Security Scan

1.  Build your Docker image locally:
    ```bash
    docker build -t my-app:local .
    ```

2.  Run the local scan script:
    ```bash
    ./scripts/scan-local.sh my-app:local
    ```

This will run Trivy with the same settings as the CI pipeline, giving you an early warning about potential vulnerabilities.