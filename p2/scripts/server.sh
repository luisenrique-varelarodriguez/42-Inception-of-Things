#! /bin/sh

# Install k3s
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -

# Wait for the K3s API server to be ready
while ! kubectl get nodes > /dev/null 2>&1 ; do
  echo "Waiting for K3s to start..."
  sleep 2
done
echo "K3S is ready!"

# Apply deployments
kubectl apply -f /vagrant_shared/deployments/app1.yml
kubectl apply -f /vagrant_shared/deployments/app2.yml
kubectl apply -f /vagrant_shared/deployments/app3.yml

# Wait for resources to be available
kubectl wait --for=condition=available --timeout=600s deployment --all

# Apply services
kubectl apply -f /vagrant_shared/services/app1.yml
kubectl apply -f /vagrant_shared/services/app2.yml
kubectl apply -f /vagrant_shared/services/app3.yml

# Apply ingress
kubectl apply -f /vagrant_shared/ingress/ingress.yml