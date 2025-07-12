#! /bin/sh

# install k3s in agent mode
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--flannel-iface=eth1" \
  K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN_FILE=/vagrant_shared/token \
  sh -
