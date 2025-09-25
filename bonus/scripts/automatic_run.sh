#!/bin/sh
set -euo pipefail

sh ./scripts/00_requirements.sh
sh ./scripts/10_k3d_cluster.sh
sh ./scripts/20_helm.sh
sh ./scripts/30_argocd.sh
sh ./scripts/40_gitlab.sh

echo ""
echo "PAUSA MANUAL REQUERIDA:"
echo "1. Accede a GitLab: http://localhost:18082"
echo "2. Sube este repositorio al GitLab interno"
echo "3. Luego ejecuta: ./scripts/50_app_chart.sh && ./scripts/60_port_forward.sh"
echo ""
