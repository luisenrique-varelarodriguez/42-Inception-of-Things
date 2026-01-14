# Part 1 - K3s Cluster with Vagrant

## 📋 Description

This project implements a basic **K3s** cluster using **Vagrant** and **VirtualBox**, consisting of two Alpine Linux virtual machines: a server (master) and a worker node.

### Objective

Set up a lightweight Kubernetes cluster using K3s in a virtualized environment, establishing communication between nodes through a private network.

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────┐
│              Host Machine               │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │    VirtualBox Private Network     │  │
│  │         192.168.56.0/24           │  │
│  │                                   │  │
│  │  ┌──────────────┐   ┌───────────┐ │  │
│  │  │  RobrodriS   │   │RobrodriSW │ │  │
│  │  │  (Server)    │   │ (Worker)  │ │  │
│  │  │ .110:6443    │◄──┤  .111     │ │  │
│  │  │  K3s Master  │   │ K3s Agent │ │  │
│  │  └──────┬───────┘   └─────┬─────┘ │  │
│  │         │                 │       │  │
│  │         └─────┬───────────┘       │  │
│  │               │                   │  │
│  └───────────────┼───────────────────┘  │
│                  │                      │
│          ┌───────▼────────┐             │
│          │  ./shared/     │             │
│          │  (token file)  │             │
│          └────────────────┘             │
└─────────────────────────────────────────┘
```

### Components

| Component  | Hostname   | IP             | Role                       | Resources      |
|------------|------------|----------------|----------------------------|----------------|
| **Server** | RobrodriS  | 192.168.56.110 | K3s Server (Control Plane) | 2GB RAM, 1 CPU |
| **Worker** | RobrodriSW | 192.168.56.111 | K3s Agent (Worker Node)    | 2GB RAM, 1 CPU |

---

## 📁 Project Structure

```
p1/
├── Vagrantfile             # VMs configuration
├── scripts/
│   ├── server.sh           # Server provisioning script
│   └── worker.sh           # Worker provisioning script
└── shared/                 # Shared folder (auto-generated)
    └── token               # K3s authentication token
```

---

## ⚙️ Detailed Configuration

### Vagrantfile

- **Base Box**: `generic/alpine318` (Alpine Linux 3.18)
- **Private Network**: `192.168.56.0/24`
- **Shared Folder**: `./shared` → `/vshared` (on both VMs)
- **Trigger**: Automatic cleanup of `./shared` when running `vagrant destroy`

### Provisioning Scripts

#### 📜 `server.sh`

Installs and configures K3s as server (control plane):

```bash
# Installation with Flannel on eth1
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -

# Copy authentication token to shared folder
cp /var/lib/rancher/k3s/server/token /vshared
```

**Features**:
- Active wait until K3s is fully started
- Monitors logs and service status
- Exports token so worker can join the cluster

#### 📜 `worker.sh`

Installs K3s as agent and connects it to the server:

```bash
# Installation in agent mode
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--flannel-iface=eth1" \
  K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN_FILE=/vshared/token \
  sh -
```

**Key parameters**:
- `K3S_URL`: K3s server endpoint
- `K3S_TOKEN_FILE`: Path to shared token
- `--flannel-iface=eth1`: Network interface for Flannel CNI

---

## 🚀 Usage

### 1. Prerequisites

- [VirtualBox](https://www.virtualbox.org/) installed
- [Vagrant](https://www.vagrantup.com/) installed
- Minimum 4GB of available RAM

### 2. Start the Cluster

```bash
# From the p1/ directory
vagrant up
```

**Process**:
1. Downloads Alpine Linux box (if not present)
2. Creates both VMs with specified configuration
3. Runs provisioning scripts
4. Generates shared token

### 3. Access the VMs

```bash
# Server
vagrant ssh RobrodriS

# Worker
vagrant ssh RobrodriSW
```

### 4. Verify the Cluster

From the server:

```bash
vagrant ssh RobrodriS
sudo kubectl get nodes -o wide
```

**Expected output**:
```
NAME          STATUS   ROLES                  AGE   VERSION
robrodris     Ready    control-plane,master   5m    v1.28.x+k3s1
robrodrissw   Ready    <none>                 4m    v1.28.x+k3s1
```

---

## ✅ Verification and Testing

### VMs Status

```bash
# Check virtual machines status
vagrant status

# Should display:
# RobrodriS   running
# RobrodriSW  running
```

### Verify K3s Services

```bash
# On the server
vagrant ssh RobrodriS
sudo rc-service k3s status
sudo cat /var/log/k3s.log | tail -20

# On the worker
vagrant ssh RobrodriSW
sudo rc-service k3s-agent status
cat /var/log/k3s-agent.log | tail -20
```

### Check Shared Token

```bash
# From the host
cat p1/shared/token

# From the server
vagrant ssh RobrodriS
cat /vshared/token
```

### Network Connectivity Test

```bash
# From server to worker
vagrant ssh RobrodriS
ping -c 4 192.168.56.111

# From worker to server
vagrant ssh RobrodriSW
ping -c 4 192.168.56.110
```

### Verify System Pods

```bash
vagrant ssh RobrodriS
sudo kubectl get pods -A

# All pods should be in Running state:
# - kube-system: coredns, metrics-server, traefik
```

### Deploy Test Application

```bash
vagrant ssh RobrodriS

# Create a deployment
sudo kubectl create deployment nginx-test --image=nginx:alpine

# Verify the pod
sudo kubectl get pods -o wide

# Create a service
sudo kubectl expose deployment nginx-test --port=80 --type=NodePort

# View the service
sudo kubectl get svc nginx-test
```

---

## 📊 Technical Information

### Network and Communication

- **CNI**: Flannel (configured on `eth1`)
- **API Server**: Port `6443` on the server
- **Pod IP Range**: `10.42.0.0/16` (K3s default)
- **Service IP Range**: `10.43.0.0/16` (K3s default)

### Authentication

The authentication token is stored at:
- **Server**: `/var/lib/rancher/k3s/server/token`
- **Shared**: `/vshared/token` (on VMs) / `./shared/token` (on host)

### Useful Commands

```bash
# View detailed node information
sudo kubectl describe nodes

# View cluster resources
sudo kubectl top nodes  # (requires metrics-server)

# View kubeconfig configuration
sudo cat /etc/rancher/k3s/k3s.yaml

# Restart K3s services
sudo rc-service k3s restart        # On server
sudo rc-service k3s-agent restart  # On worker
```

---

## 🧹 Cleanup

### Stop the VMs

```bash
vagrant halt
```

### Destroy the Complete Environment

```bash
vagrant destroy -f
```

**Note**: The configured trigger will automatically remove the `shared/` folder when destroying the VMs.

### Clean Downloaded Boxes

```bash
# List installed boxes
vagrant box list

# Remove Alpine box (optional)
vagrant box remove generic/alpine318
```

---

## 🐛 Troubleshooting

### VMs Don't Start

```bash
# Check VirtualBox
VBoxManage list vms

# View detailed logs
vagrant up --debug
```

### Worker Doesn't Join the Cluster

```bash
# Verify token exists
vagrant ssh RobrodriSW
cat /vshared/token

# Verify connectivity to server
ping 192.168.56.110
curl -k https://192.168.56.110:6443

# View agent logs
cat /var/log/k3s-agent.log
```

### Network Issues Between Nodes

```bash
# Check network interfaces
ip addr show

# Verify eth1 has the correct IP
ip addr show eth1

# Check routes
ip route
```

---

## 📚 References

- [K3s Documentation](https://docs.k3s.io/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [Alpine Linux Wiki](https://wiki.alpinelinux.org/)
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)

---

## ✨ Expected Result

A functional Kubernetes cluster with:

✅ 2 nodes (1 server + 1 worker) in `Ready` state  
✅ Communication established through private network  
✅ System pods running correctly  
✅ Token-based authentication  
✅ Flannel CNI configured and operational
