#!/bin/sh
set -euo pipefail

echo "[50] Validando chart y aplicando Application ArgoCD…"

CHART_DIR="/vagrant/confs/charts/wil42"
APP_FILE="/vagrant/confs/argocd/wil42-app.yaml"

# Comprobación de archivos
[ -f "${CHART_DIR}/Chart.yaml" ] || { echo "Falta ${CHART_DIR}/Chart.yaml"; exit 1; }
[ -f "${CHART_DIR}/values.yaml" ] || { echo "Falta ${CHART_DIR}/values.yaml"; exit 1; }
[ -f "${CHART_DIR}/templates/deployment.yaml" ] || { echo "Falta deployment.yaml"; exit 1; }
[ -f "${CHART_DIR}/templates/service.yaml" ] || { echo "Falta service.yaml"; exit 1; }
[ -f "${CHART_DIR}/templates/ingress.yaml" ] || { echo "Falta ingress.yaml"; exit 1; }
[ -f "${APP_FILE}" ] || { echo "Falta ${APP_FILE} (Application de ArgoCD)"; exit 1; }

# Crear namespace
kubectl create namespace dev 2>/dev/null || true

# Apply de la app
kubectl apply -f "${APP_FILE}"

echo " - Application aplicada. Abre ArgoCD y verifica sincronización."
