#!/bin/sh
set -euo pipefail

# Load logging functions
. "$(dirname "$0")/logging.sh"

log_header "00" "Installing prerequisites"

# Base packages
log_info "Updating package repositories"
apk update >/dev/null 2>&1

log_info "Installing base packages (bash, curl, tar, git, sudo)"
apk add --no-cache bash curl tar git sudo >/dev/null 2>&1
log_success "Base packages installed"

# Docker
log_info "Installing Docker"
if ! command -v dockerd >/dev/null 2>&1; then
  apk add --no-cache docker >/dev/null 2>&1
  rc-update add docker default >/dev/null 2>&1
  service docker start >/dev/null 2>&1
  log_success "Docker installed and started"
else
  log_info "Docker already installed, starting service"
  service docker start >/dev/null 2>&1 || true
  log_success "Docker started"
fi

# Add current user to docker group
log_info "Adding current user to docker group"
if id "$USER" >/dev/null 2>&1; then
  addgroup "$USER" docker >/dev/null 2>&1 || true
  log_success "User $USER added to docker group"
else
  log_warning "Could not identify current user"
fi

# kubectl
log_info "Installing kubectl"
if [ ! -x /usr/local/bin/kubectl ]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" >/dev/null 2>&1
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl

  echo "alias k='kubectl'" >> "$HOME/.profile"
  log_success "kubectl installed and configured (alias 'k')"
else
  log_info "kubectl already installed"
fi

# k3d
log_info "Installing k3d"
if [ ! -x /usr/local/bin/k3d ]; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash >/dev/null 2>&1
  log_success "k3d installed successfully"
else
  log_info "k3d already installed"
fi

# k9s
log_info "Installing k9s (Kubernetes UI)"
if ! command -v k9s >/dev/null 2>&1; then
  apk add --no-cache k9s >/dev/null 2>&1
  log_success "k9s installed successfully"
else
  log_info "k9s already installed"
fi
