#!/bin/sh
set -euo pipefail

echo "[00] Instalando prerequisitos..."

# Paquete base
apk update
apk add --no-cache bash curl tar git sudo

# Docker
if ! command -v dockerd >/dev/null 2>&1; then
  apk add --no-cache docker
  rc-update add docker default
  service docker start
else
  service docker start || true
fi

# Añadimos el usuario actual al grupo docker
if id "$USER" >/dev/null 2>&1; then
  addgroup "$USER" docker || true
fi

# kubectl
if [ ! -x /usr/local/bin/kubectl ]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  # Añadimos el alias k para kubectl en ~/.profile del usuario actual
  echo "alias k='kubectl'" >> "$HOME/.profile"
  chown "$USER":"$USER" "$HOME/.profile"
fi

# k3d
if [ ! -x /usr/local/bin/k3d ]; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# k9s
if ! command -v k9s >/dev/null 2>&1; then
  apk add --no-cache k9s
fi
