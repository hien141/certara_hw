# Certara Cloud Engineering Homework

This repository contains a unified, multi-tier platform engineering suite split into two clear execution spaces:
1. **Cloud Infrastructure Blueprint (`/terraform`)**: A modular, secure, production-grade AWS networking and storage workspace.
2. **Local Application Sandbox (`/rest-service-k8s`)**: An automated, zero-registry local development loop designed to package, deploy, and expose a pre-compiled Go REST service out-of-the-box inside a local Kubernetes (`minikube`) cluster.

---

## 🏗️ Repository Architecture Layout

```text
certara_hw/
├── README.md                # Core technical documentation
├── .gitignore               # Global exclusion boundaries for binaries and caches
├── rest-service-k8s/        # Local Kubernetes Application Loop
│   ├── skaffold.yaml        # Continuous deployment orchestrator
│   ├── run.sh               # One-click bootstrap script
│   ├── app/
│   │   ├── Dockerfile       # Multi-architecture container configuration
│   │   └── rest_1.0_*       # Pre-compiled multi-platform native Go binaries
│   └── k8s/
│       ├── deployment.yaml  # Declarative pod & replica container state
│       └── service.yaml     # Internal service mesh network map
└── terraform/               # Enterprise Cloud Infrastructure
    ├── main.tf              # Root environment driver
    ├── s3_backup.tf         # Secure data persistence & lifecycle configuration
    └── modules/ 
        └── vpc/             # Reusable core networking block
            ├── main.tf      # Subnets, Gateways, Routes, and Endpoints
            ├── outputs.tf   # Exported resource attribute signatures
            └── variables.tf # Strict variable parameter input boundaries

```

---

## 🛠️ Part 1: Cloud Infrastructure Workspace (Terraform)

The Terraform workspace defines a secure virtual datacenter module paired with a protected data storage plane located within the AWS Frankfurt (`eu-central-1`) region.

### Core Architectural Features

* **Modular VPC Networking:** Builds 4 independent subnets (2 Public, 2 Private) distributed across 2 Availability Zones (`eu-central-1a` and `eu-central-1b`) for high-availability.
* **Asymmetric Security Gateways:** Public subnets host Internet Gateways and NAT Gateways, allowing instances in private layers to download security patches securely without direct external exposure.
* **Cost-Optimized Private Routing:** Implements an **AWS S3 VPC Gateway Endpoint**. Traffic routing from private subnets to the S3 backup vault travels completely inside AWS's internal private fiber backbone, entirely bypassing NAT processing fees and improving throughput.
* **Compliant Data Persistence:** Provisions a locked-down, encrypted S3 bucket featuring an active lifecycle rule configuration: automatically transitioning files to `Standard-IA` after 30 days and permanently pruning them after 180 days.

### Infrastructure Provisioning Steps

1. Navigate to the infrastructure engine directory:
```bash
cd terraform

```


2. Initialize the backend tracking hooks and download required AWS providers:
```bash
terraform init

```


3. Generate a speculative execution matrix to preview upcoming resource changes:
```bash
terraform plan

```


4. Build the live cloud infrastructure layer in AWS:
```bash
terraform apply

```
*(Note: terraform apply is optional; environment compliance is fully verifiable via terraform plan to avoid live AWS resource overhead)*


---

## ☸️ Part 2: Local Application Sandbox (Kubernetes)

This space provides an automated development workspace framework for engineers to instantly test and run the Go REST application inside a local Minikube cluster without needing advanced Kubernetes expertise.

### Automation & Cost-Saving Features

* **Cross-Platform Compatibility Script:** The master script (`run.sh`) sniffs the developer's host machine hardware architecture (`uname -m`), automatically copying and standardizing the correct `amd64` or `arm64` pre-compiled Linux binary into the Docker context.
* **Zero Remote Registry Fees:** Redirects the local shell hook context directly into Minikube’s internal Docker storage cache via `eval $(minikube docker-env)`. Containers are compiled directly inside the cluster, eliminating external registry bandwidth costs, cloud hosting fees, and push/pull delays.
* **Deterministic Local Routing:** Cleans out historical rogue system processes blocking port `8080` using `pkill`, spins up the deployment, and establishes a persistent background port-forwarding tunnel bridging the service right onto your localhost layer.

### Local Execution Prerequisites

Ensure your local development machine has the following tools installed:

* **Docker Engine / Desktop**
* **Minikube**
* **kubectl**
* **Skaffold**

### One-Click Local Deployment Guide

1. Navigate to the application sandbox root:
```bash
cd rest-service-k8s

```


2. Grant execution rights to the master automation wrapper script:
```bash
chmod +x run.sh

```


3. Execute the script to bootstrap your workspace:
```bash
./run.sh

```



The script will automatically execute pre-flight dependency audits using explicit Bash indexed arrays (`declare -a bin_dependencies`), boot up Minikube using the containerized `docker` driver, trigger Skaffold to compile the image locally inside the cluster, inject declarative resources, and mount your network route point.

---

## 🔌 Network Port-Forwarding & Validation

Because Kubernetes operates on its own private internal network mesh topology, the container running inside Minikube cannot be reached directly by your workstation's browser or `curl` client by default.

To bridge this boundary, a secure network tunnel must be created to route local host machine traffic straight into the cluster service mesh.

### Manual Network Tunnel Initialization

The `run.sh` script handles this cleanly in the background. However, if you ever need to establish or reset the connection tunnel manually to access the service application, spin up a foreground port-forward using `kubectl`:

```bash
# Form a secure TCP tunnel mapping host port 8080 to the internal cluster service port 8080
kubectl port-forward svc/rest-service 8080:8080

```

*(Note: Keep this command or the background script running to preserve your pipeline connection while testing).*

### Verifying the Application Endpoint

Once the initialization sequence finishes cleanly and the port-forwarding tunnel is active, test the live container from your terminal:

```bash
curl -i http://localhost:8080/hello-world

```

#### Expected JSON Response Payload:

```http
HTTP/1.1 200 OK
Date: Thu, 28 May 2026 08:55:03 GMT
Content-Length: 27
Content-Type: text/plain; charset=utf-8

{"message":"Hello World!"}

```

---

## 🛑 Clean Up & Resource Teardown

### Stopping the Local Kubernetes Cluster

To temporarily suspend Minikube and reclaim your host machine’s RAM and CPU without deleting your cluster state, run:

```bash
minikube stop
pkill -f "kubectl port-forward"

```

### Destroying Cloud Infrastructure

To tear down your remote AWS architecture assets completely and avoid ongoing cloud provider costs, navigate to the Terraform directory and run:

```bash
cd terraform
terraform destroy

```

### 🚀 Push the Finished Document to GitHub

With your workspace completely stabilized, sync the final asset to your remote repository:

```bash
git add README.md
git commit -m "docs: compile unified cloud and local cluster engineering readme documentation"
git push

```
