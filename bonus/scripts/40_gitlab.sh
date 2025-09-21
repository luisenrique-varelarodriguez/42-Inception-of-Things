#!/bin/sh
set -euo pipefail

echo "[40] Instalando GitLab… (esto puede tardar varios minutos)"

# Namespace
kubectl create namespace gitlab 2>/dev/null || true

# Añadir repo GitLab
helm repo add gitlab https://charts.gitlab.io/ || true
helm repo update

sleep 30

# Configuración mínima optimizada para k3d con reintentos automáticos globales
# https://docs.gitlab.com/charts/installation/deployment.html
#	https://gitlab.com/gitlab-org/charts/gitlab/-/tree/master/examples?ref_type=heads
helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --set global.initialRootPassword.password=iot42. \
  --set gitlab.migrations.restartPolicy=OnFailure \
  --set gitlab.migrations.backoffLimit=100000 \
  --set global.deployment.restartPolicy=Always \
  --set global.pod.restartPolicy=Always \
  --set gitlab.webservice.deployment.restartPolicy=Always \
  --set gitlab.sidekiq.deployment.restartPolicy=Always \
  --set gitlab.gitaly.deployment.restartPolicy=Always \
  --wait \
  --timeout 1800s

# Esperar webservice listo
echo " - esperando GitLab webservice…"
kubectl -n gitlab rollout status deploy/gitlab-webservice-default --timeout=1200s || true

# Credenciales y acceso
echo " - Usuario: root"
echo " - Password: iot42."
echo " - URL: http://gitlab.localhost"
