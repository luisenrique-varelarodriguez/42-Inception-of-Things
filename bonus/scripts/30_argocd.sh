#!/bin/sh
set -euo pipefail

echo "[30] Instalando Argo CD…"

# Namespace
kubectl create namespace argocd 2>/dev/null || true

# Añadir repo ArgoCD
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo update

# Valores con Ingress traefik
VALUES="/vagrant/confs/helm-values/argocd-values.yaml"

helm upgrade --install argocd argo/argo-cd \
  -n argocd \
  -f "${VALUES}"

# Esperar server listo
kubectl -n argocd rollout status deploy/argocd-server --timeout=600s || true

echo " - Password admin ArgoCD: holasoyadmin"
