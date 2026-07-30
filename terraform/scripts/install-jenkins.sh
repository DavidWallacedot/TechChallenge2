#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y docker git

systemctl enable --now docker

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
  https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

docker --version
docker compose version

rm -rf /opt/TechChallenge2

git clone \
  --branch jenkins \
  --single-branch \
  https://github.com/DavidWallacedot/TechChallenge2.git \
  /opt/TechChallenge2

cd /opt/TechChallenge2

docker compose -f jenkins/docker-compose.yml up -d --build