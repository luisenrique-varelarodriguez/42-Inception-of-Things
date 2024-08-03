#! /bin/sh

# Install docker
echo "Installing Docker"
apk update && apk add docker
addgroup $USER docker
rc-update add docker default
service docker start
# Install kubectl
echo "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# k3D is a wrapper for k3s
echo "Installing k3d"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
# Install k9s because it's cool
apk add k9s

# Create the cluster
k3d cluster create --agents 3 core
# create the namespaces
kubectl create namespace dev
kubectl create namespace argocd
# create deployments
# argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Wait for ArgoCD pods to be ready
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=600s

# setting pass for argocd dashboard pass -> holasoyadmin
sudo kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$12$gbR7bIATHJekG9kAW3pt4eoTeru957RpeotGGluQ5mS50wTm5bYU2",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
# Apply ArgoCD application configuration
kubectl apply -f /vagrant_shared/deployments/argo.yml
# app
# kubectl apply -n dev -f /vagrant_shared/app.yml