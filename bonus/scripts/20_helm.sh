#!/bin/sh
set -euo pipefail

# Load logging functions
. "$(dirname "$0")/logging.sh"

log_header "20" "Installing Helm"

# Helm
log_info "Installing Helm"
if ! command -v helm >/dev/null 2>&1; then
  curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >/dev/null 2>&1
  log_success "Helm installed successfully"
else
  log_info "Helm already installed"
fi
