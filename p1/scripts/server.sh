#! /bin/sh

# Function to check the status of K3s
check_k3s_status() {
  rc-service k3s status
}

# Function to display logs (last 20 lines) from K3s
display_k3s_logs() {
  cat /var/log/k3s.log | tail -n 20
}

# Install k3s
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -

# Wait for k3s to start
echo "Waiting for K3s to start..."
while ! kubectl get nodes > /dev/null 2>&1; do
  echo "K3s is not running yet. Checking status and displaying logs..."
  check_k3s_status
  display_k3s_logs
  sleep 2
done

# Copy server token to shared folder
chmod 644 /var/lib/rancher/k3s/server/token
cp /var/lib/rancher/k3s/server/token /vagrant_shared
