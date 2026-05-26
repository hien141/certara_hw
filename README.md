# Certara Cloud Engineering Challenge

This repository contains a unified, multi-tier platform engineering suite split into two clear execution spaces:
1. **Cloud Infrastructure Blueprint (`/terraform`)**: A modular, secure, production-grade AWS networking and storage workspace.
2. **Local Application Sandbox (`/rest-service-k8s`)**: An automated, zero-registry local development loop designed to package, deploy, and expose a pre-compiled Go REST service out-of-the-box inside a local Kubernetes (`minikube`) cluster.

---

## 🏗️ Repository Architecture Layout

```text
certara_hw/
├── README.md               # Core technical documentation
├── rest-service-k8s/       # Local Kubernetes Application Loop
│   ├── skaffold.yaml       # Continuous deployment orchestrator
│   ├── run.sh              # One-click bootstrap script
│   ├── app/
│   │   ├── Dockerfile      # Multi-architecture container configuration
│   │   └── rest_1.0_* # Pre-compiled multi-platform native binaries
│   └── k8s/
│       ├── deployment.yaml # Declarative pod & replica container state
│       └── service.yaml    # Internal service mesh network map
└── terraform/              # Enterprise Cloud Infrastructure
    ├── main.tf             # Root environment driver
    ├── s3_backup.tf        # Secure data persistence & lifecycle configuration
    └── modules/
        └── vpc/            # Reusable core networking block
            ├── main.tf     # Subnets, Gateways, Routes, and Endpoints
            ├── outputs.tf  # Exported resource attribute signatures
            └── variables.tf# Strict variable parameter input boundaries
