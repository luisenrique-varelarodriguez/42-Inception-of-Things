#! /bin/sh

ip addr add 192.168.56.110/24 broadcast 192.168.56.255 dev eth1
ip link set dev eth1 up
# Function to check the status of K3s
check_k3s_status() {
  systemctl is-active k3s
}

# Function to display logs
display_k3s_logs() {
  journalctl -u k3s --no-pager -n 20
}
# install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -
# wait k3s to start
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