# p1 - K3s Cluster with Vagrant

This directory contains the configuration for a K3s cluster using two Alpine Linux virtual machines managed by Vagrant.

## Structure

- **Vagrantfile**: Defines two VMs (`RobrodriS` and `RobrodriSW`) using the `generic/alpine318` box. Sets up private networking and a shared folder.
- **scripts/**
  - `server.sh`: Installs K3s server (master node) on `RobrodriS`.
  - `worker.sh`: Installs K3s agent (worker node) on `RobrodriSW`.
- **shared/**: Shared folder between the host and both VMs, mounted at `/vshared` inside the VMs. Contains the K3s token for cluster joining.

## Virtual Machines

- **RobrodriS**: K3s server (master), IP `192.168.56.110`
- **RobrodriSW**: K3s worker, IP `192.168.56.111`

## Usage

1. Start the VMs:
   ```sh
   vagrant up
   ```

2. SSH into the VMs:
   ```sh
   vagrant ssh RobrodriS
   vagrant ssh RobrodriSW
   ```

3. Provisioning scripts are executed automatically when the VMs are created.

## Testing & Verification

<details>
<summary>Click to expand verification steps</summary>

### 1. Check VMs Status
```sh
vagrant status
```

### 2. Verify K3s Server
```sh
vagrant ssh RobrodriS
```

Inside the server VM:
```sh
# Check K3s service status
sudo rc-service k3s status

# Verify nodes in the cluster
sudo kubectl get nodes

# Check nodes details
sudo kubectl get nodes -o wide
```

### 3. Verify Token Sharing
```sh
# Inside server VM
ls -la /vshared/
cat /vshared/token

# On host machine
ls -la p1/shared/
cat p1/shared/token
```

### 4. Verify K3s Worker
```sh
vagrant ssh RobrodriSW
```

Inside the worker VM:
```sh
# Check K3s agent service status
sudo rc-service k3s-agent status

# View logs
cat /var/log/k3s-agent.log
```

### 5. Verify Cluster Connectivity
From the server VM:
```sh
sudo kubectl get nodes
```
You should see both nodes:
- `robrodris` (server/master)
- `robrodrissw` (worker)

### 6. Check System Pods
```sh
# Inside server VM
sudo kubectl get pods -A
```
All pods should be in `Running` state.

### 7. Test Deployment
```sh
# Create a test deployment
sudo kubectl create deployment test-nginx --image=nginx
sudo kubectl get pods
sudo kubectl get deployments
```

### 8. Network Connectivity Test
```sh
# From server to worker
vagrant ssh RobrodriS
ping 192.168.56.111

# From worker to server
vagrant ssh RobrodriSW
ping 192.168.56.110
```

## Expected Result

A functional K3s cluster with:
- 1 master node (RobrodriS)
- 1 worker node (RobrodriSW)
- All system pods running
- Token-based authentication working
- Network connectivity between nodes

## Cleanup

To destroy the VMs and clean up:
```sh
vagrant destroy
```
The shared folder will be automatically removed thanks to the trigger configuration.

</details>
