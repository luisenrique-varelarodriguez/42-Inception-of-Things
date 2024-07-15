#! /bin/sh

# install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -
# wait k3s to start
while ! kubectl get nodes > /dev/null 2>&1; do
  echo "Waiting for K3s to start..."
  sleep 2
done
# Copy server token to shared folder
chmod 644 /var/lib/rancher/k3s/server/token
cp /var/lib/rancher/k3s/server/token /vagrant_shared