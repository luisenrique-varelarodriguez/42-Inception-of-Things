#!/bin/sh
set -euo pipefail

echo "[20] Instalando Helm y repos…"

# Helm
if ! command -v helm >/dev/null 2>&1; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
