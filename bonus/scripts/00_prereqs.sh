#!/bin/sh
set -euo pipefail

echo "[00] Instalando prerequisitos..."

# Paquete base
apk update
apk add --no-cache bash curl tar git

# Docker
if ! command -v dockerd >/dev/null 2>&1; then
  apk add --no-cache docker
  rc-update add docker default
  service docker start
else
  service docker start || true
fi

# Añadimos el usuario vagrant al grupo docker
if id vagrant >/dev/null 2>&1; then
  addgroup vagrant docker || true
fi

# kubectl
KUBECTL_VER="v1.33.5"
if [ ! -x /usr/local/bin/kubectl ]; then
  curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VER}/bin/linux/amd64/kubectl"
  chmod +x /usr/local/bin/kubectl
fi

# k3d
K3D_VER="v5.6.3"
if [ ! -x /usr/local/bin/k3d ]; then
  curl -L -o /usr/local/bin/k3d "https://github.com/k3d-io/k3d/releases/download/${K3D_VER}/k3d-linux-amd64"
  chmod +x /usr/local/bin/k3d
fi
