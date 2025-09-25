#!/bin/sh
set -euo pipefail

echo "[10] Creando cluster k3d…"

CLUSTER="iot-cluster"

if k3d cluster list | grep -q "^${CLUSTER}\b"; then
  echo " - cluster ${CLUSTER} ya existe"
else
  k3d cluster create "${CLUSTER}" \
    --k3s-arg "--disable=servicelb@server:0"
fi

# Esperar a que el API responda
kubectl version --client

# Esperar a que traefik esté disponible
echo " - esperando traefik…"
sleep 20
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=traefik -n kube-system --timeout=300s || \
  echo " - traefik no disponible, continuando..."
