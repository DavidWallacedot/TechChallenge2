#!/bin/bash
set -euxo pipefail

DOCKER_COMPOSE_VERSION="v2.39.1"
HELM_VERSION="v4.2.3"
KUBECTL_VERSION="v1.33.0"

# Values injected by Terraform templatefile()
AWS_REGION="${aws_region}"
EKS_CLUSTER_NAME="${cluster_name}"

dnf update -y

dnf install -y \
  docker \
  git \
  tar \
  gzip \
  unzip \
  jq

systemctl enable --now docker

# Install Docker Compose CLI plugin on the EC2 host
mkdir -p /usr/local/lib/docker/cli-plugins

curl -fsSL \
  "https://github.com/docker/compose/releases/download/$${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod 0755 /usr/local/lib/docker/cli-plugins/docker-compose

# Install kubectl on the EC2 host
curl -fsSL \
  "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  -o /usr/local/bin/kubectl

chmod 0755 /usr/local/bin/kubectl

# Install Helm on the EC2 host
curl -fsSL \
  "https://get.helm.sh/helm-$${HELM_VERSION}-linux-amd64.tar.gz" \
  -o /tmp/helm.tar.gz

tar -xzf /tmp/helm.tar.gz -C /tmp

install -m 0755 \
  /tmp/linux-amd64/helm \
  /usr/local/bin/helm

rm -rf /tmp/linux-amd64 /tmp/helm.tar.gz

# Verify tools installed on the EC2 host
docker --version
docker compose version
aws --version
kubectl version --client
helm version

# Configure kubeconfig for host-level administration and troubleshooting
mkdir -p /root/.kube

aws eks update-kubeconfig \
  --name "$EKS_CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --kubeconfig /root/.kube/config

# Clone the Jenkins branch
rm -rf /opt/TechChallenge2

git clone \
  --branch jenkins \
  --single-branch \
  https://github.com/DavidWallacedot/TechChallenge2.git \
  /opt/TechChallenge2

cd /opt/TechChallenge2

# Build the custom Jenkins image and start Jenkins
docker compose \
  -f jenkins/docker-compose.yml \
  up -d --build

# Verify the Jenkins container is running
docker ps

# Verify deployment tools inside the Jenkins container
docker exec techchallenge2-jenkins aws --version || true
docker exec techchallenge2-jenkins kubectl version --client || true
docker exec techchallenge2-jenkins helm version || true
docker exec techchallenge2-jenkins docker --version || true