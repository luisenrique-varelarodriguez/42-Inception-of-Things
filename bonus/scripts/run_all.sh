#!/bin/sh
set -euo pipefail

sh ./scripts/00_prereqs.sh
sh ./scripts/10_k3d_cluster.sh
sh ./scripts/20_helm.sh
sh ./scripts/30_argocd.sh
sh ./scripts/40_gitlab.sh
