#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Starting workspace initialization...${NC}"

# Step 1: Pre-flight tool checking
declare -a bin_dependencies=("minikube" "kubectl" "docker" "skaffold")
for binary in "${bin_dependencies[@]}"; do
    if ! command -v "$binary" &> /dev/null; then
        echo -e "${RED}❌ Missing dependency error: '$binary' is not installed.${NC}"
        exit 1
    fi
done

# Step 2: Architecture Detection & Context Preparation
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    echo -e "${GREEN}🖥️ Intel/AMD (amd64) architecture detected.${NC}"
    cp app/rest_1.0_linux_amd64 app/rest-backend
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    echo -e "${GREEN}🍏 ARM (arm64) architecture detected.${NC}"
    cp app/rest_1.0_linux_arm64 app/rest-backend
else
    echo -e "${RED}❌ Unsupported system architecture: $ARCH${NC}"
    exit 1
fi

# Step 3: Ensure Minikube is up and healthy
if ! minikube status &> /dev/null; then
    echo -e "${YELLOW}⚙️ Minikube is offline. Starting cluster...${NC}"
    minikube start --driver=docker
else
    echo -e "${GREEN}✅ Existing Minikube cluster detected and active.${NC}"
fi

# Step 4: Align host shell context to the internal Minikube daemon
echo -e "${YELLOW}⚙️ Pointing shell to Minikube's Docker Engine...${NC}"
eval $(minikube -p minikube docker-env)

# Step 5: Run Skaffold build & deployment loop
echo -e "${YELLOW}📦 Packaging pre-compiled binary and updating manifests...${NC}"
skaffold run

# Step 6: Expose the service locally
echo -e "${YELLOW}🌐 Bridging service endpoint via background tunnel...${NC}"
pkill -f "minikube service rest-service" || true
minikube service rest-service --url > /dev/null 2>&1 &

echo -e "\n${GREEN}====================================================${NC}"
echo -e "${GREEN}🎉 Initialization Sequence Complete!${NC}"
echo -e "👉 ${YELLOW}curl http://localhost:8080/hello-world${NC}"
echo -e "${GREEN}====================================================${NC}\n"
