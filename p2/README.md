# Part 2 - K3s with Applications and Ingress

## 📋 Description

This project sets up a single-node **K3s** cluster with multiple web applications and an **Ingress controller** for routing. The environment is fully automated using **Vagrant** and **VirtualBox**, with three sample applications deployed and accessible through host-based routing.

### Objective

Deploy a lightweight Kubernetes cluster with multiple applications, demonstrate Ingress routing capabilities, and showcase automatic provisioning and deployment of Kubernetes resources.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│                Host Machine                 │
│                192.168.56.1                 │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │       VirtualBox Private Network       │ │
│  │            192.168.56.0/24             │ │
│  │                                        │ │
│  │  ┌───────────────────────────────────┐ │ │
│  │  │            RobrodriS              │ │ │
│  │  │          192.168.56.110           │ │ │
│  │  │                                   │ │ │
│  │  │  ┌──────────────────────────────┐ │ │ │
│  │  │  │   K3s Cluster (Single Node)  │ │ │ │
│  │  │  │                              │ │ │ │
│  │  │  │  ┌─────────────────────────┐ │ │ │ │
│  │  │  │  │     Traefik Ingress     │ │ │ │ │
│  │  │  │  │       (Controller)      │ │ │ │ │
│  │  │  │  └──────────┬──────────────┘ │ │ │ │
│  │  │  │             │                │ │ │ │
│  │  │  │  ┌──────────┴──────────┐     │ │ │ │
│  │  │  │  │                     │     │ │ │ │
│  │  │  │  ▼          ▼          ▼     │ │ │ │
│  │  │  │  app1      app2       app3   │ │ │ │
│  │  │  │  (1 pod)   (3 pods)  (1 pod) │ │ │ │
│  │  │  └──────────────────────────────┘ │ │ │
│  │  └───────────────────────────────────┘ │ │
│  └────────────────────────────────────────┘ │
│                                             │
│         ┌──────────────────────┐            │
│         │   ./shared/          │            │
│         │   ├─ deployments/    │            │
│         │   ├─ services/       │            │
│         │   └─ ingress/        │            │
│         └──────────────────────┘            │
└─────────────────────────────────────────────┘

Access Pattern:
app1.com → Traefik → app1 service → app1 pod
app2.com → Traefik → app2 service → app2 pods (load balanced)
*        → Traefik → app3 service → app3 pod (default)
```

### Components

| Component   | Type               | Replicas | Image                            | Purpose                           |
|-------------|--------------------|----------|----------------------------------|-----------------------------------|
| **app1**    | Deployment         | 1        | paulbouwer/hello-kubernetes:1.10 | Demo app (app1.com)               |
| **app2**    | Deployment         | 3        | paulbouwer/hello-kubernetes:1.10 | Demo app with replicas (app2.com) |
| **app3**    | Deployment         | 1        | paulbouwer/hello-kubernetes:1.10 | Default app (catch-all)           |
| **Traefik** | Ingress Controller | 1        | (bundled with K3s)               | Routes traffic                    |

---

## 📁 Project Structure

```
p2/
├── Vagrantfile             # VM configuration
├── scripts/
│   └── server.sh           # Automated provisioning script
└── shared/                 # Kubernetes manifests
    ├── deployments/
    │   ├── app1.yml        # App1 deployment (1 replica)
    │   ├── app2.yml        # App2 deployment (3 replicas)
    │   └── app3.yml        # App3 deployment (1 replica)
    ├── services/
    │   ├── app1.yml        # ClusterIP service for app1
    │   ├── app2.yml        # ClusterIP service for app2
    │   └── app3.yml        # ClusterIP service for app3
    └── ingress/
        └── ingress.yml     # Ingress rules for routing
```

---

## ⚙️ Detailed Configuration

### Vagrantfile

- **Base Box**: `generic/alpine318` (Alpine Linux 3.18)
- **Private Network**: IP `192.168.56.110`
- **Shared Folder**: `./shared` → `/vshared` (mounted in VM)
- **Resources**: 2GB RAM, 1 CPU
- **Single VM**: `RobrodriS` (all-in-one K3s node)

### Provisioning Script: `server.sh`

The script fully automates the cluster setup:

```bash
# 1. Install K3s with Flannel on eth1
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -

# 2. Wait for K3s to be ready
while ! kubectl get nodes > /dev/null 2>&1 ; do
  sleep 2
done

# 3. Deploy applications
kubectl apply -f /vshared/deployments/*.yml
kubectl wait --for=condition=available --timeout=600s deployment --all

# 4. Create services
kubectl apply -f /vshared/services/*.yml

# 5. Configure ingress
kubectl apply -f /vshared/ingress/ingress.yml
```

### Kubernetes Manifests

#### Deployments

**app1.yml** - Single replica application:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 1  # Single instance
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: paulbouwer/hello-kubernetes:1.10
        ports:
        - containerPort: 8080
```

**app2.yml** - Multi-replica application (demonstrating scaling):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 3  # Three instances for load balancing
  # ... same structure as app1
```

**app3.yml** - Default/catch-all application

#### Services

All services use **ClusterIP** type (internal access only):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app1
spec:
  type: ClusterIP
  selector:
    app: app1
  ports:
  - port: 80
    targetPort: 8080
```

#### Ingress

The Ingress resource defines routing rules:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  ingressClassName: traefik
  rules:
  - host: app1.com          # Route app1.com → app1 service
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
  - host: app2.com          # Route app2.com → app2 service
    # ... similar configuration
  - http:                   # Default rule (no host)
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app3      # Catch-all to app3
            port:
              number: 80
```

**Routing Logic**:
- `Host: app1.com` → app1 service
- `Host: app2.com` → app2 service (load balanced across 3 pods)
- No host or unknown host → app3 service (default)

---

## 🚀 Usage

### 1. Prerequisites

- [VirtualBox](https://www.virtualbox.org/) installed
- [Vagrant](https://www.vagrantup.com/) installed
- Minimum 2GB of available RAM

### 2. Start the Environment

```bash
# From the p2/ directory
vagrant up
```

**What happens automatically**:
1. ✅ VM creation and network configuration
2. ✅ K3s installation
3. ✅ Deployment of all 3 applications
4. ✅ Service creation
5. ✅ Ingress configuration
6. ✅ Ready to accept traffic

### 3. Access the VM

```bash
vagrant ssh RobrodriS
```

### 4. Verify Deployment

```bash
vagrant ssh RobrodriS

# Check all resources
sudo kubectl get all -A

# Check ingress
sudo kubectl get ingress
```

---

## ✅ Verification and Testing

### Check VM Status

```bash
vagrant status

# Expected output:
# RobrodriS   running (virtualbox)
```

### Verify K3s Service

```bash
vagrant ssh RobrodriS
sudo rc-service k3s status
sudo kubectl get nodes
```

**Expected output**:
```
NAME        STATUS   ROLES                  AGE   VERSION
robrodris   Ready    control-plane,master   5m    v1.28.x+k3s1
```

### Check Deployments and Pods

```bash
sudo kubectl get deployments

# Expected:
# NAME   READY   UP-TO-DATE   AVAILABLE   AGE
# app1   1/1     1            1           2m
# app2   3/3     3            3           2m
# app3   1/1     1            1           2m

sudo kubectl get pods -o wide

# Should see 5 pods total: 1 (app1) + 3 (app2) + 1 (app3)
```

### Check Services

```bash
sudo kubectl get svc

# All services should be ClusterIP type
```

### Check Ingress

```bash
sudo kubectl get ingress

# Should show my-ingress with 192.168.56.110 as ADDRESS
sudo kubectl describe ingress my-ingress
```

### Test Applications from Host

#### Option 1: Using curl with Host header (recommended)

No need to modify `/etc/hosts`:

```bash
# Test app1
curl -H "Host: app1.com" http://192.168.56.110/

# Test app2 (load balanced across 3 pods)
curl -H "Host: app2.com" http://192.168.56.110/

# Test app3 (default/catch-all)
curl http://192.168.56.110/
# or
curl -H "Host: anything.com" http://192.168.56.110/
```

#### Option 2: Using /etc/hosts file

Add entries to your host machine's `/etc/hosts`:

```bash
# On macOS/Linux:
sudo nano /etc/hosts

# Add these lines:
192.168.56.110 app1.com
192.168.56.110 app2.com
```

Then access via browser:
- http://app1.com/
- http://app2.com/
- http://192.168.56.110/ (default → app3)

### Verify Load Balancing (app2)

```bash
# Make multiple requests to app2
for i in {1..10}; do
  curl -H "Host: app2.com" http://192.168.56.110/ 2>/dev/null | grep -i pod
done

# You should see different pod names, demonstrating load balancing
```

### Test from Inside the VM

```bash
vagrant ssh RobrodriS

# Test internal service resolution
sudo kubectl run -it --rm debug --image=alpine --restart=Never -- sh

# Inside the debug pod:
apk add curl
curl http://app1.svc.cluster.local
curl http://app2.svc.cluster.local
curl http://app3.svc.cluster.local
```

---

## 📊 Technical Information

### Network Configuration

- **CNI**: Flannel (configured on `eth1`)
- **Ingress Controller**: Traefik (bundled with K3s)
- **Service Type**: ClusterIP (internal only)
- **External Access**: Through Ingress on port 80
- **VM IP**: `192.168.56.110`

### Pod Distribution

- **app1**: 1 pod (single instance)
- **app2**: 3 pods (demonstrates horizontal scaling and load balancing)
- **app3**: 1 pod (default backend)
- **Total**: 5 application pods

### Resource Limits

Default K3s limits apply (no custom limits set):
- No memory/CPU requests defined
- K3s will schedule based on available resources

### Useful Commands

```bash
# Watch pod status in real-time
sudo kubectl get pods -w

# View pod logs
sudo kubectl logs <pod-name>
sudo kubectl logs -l app=app2  # All app2 pods

# Scale deployments
sudo kubectl scale deployment app2 --replicas=5

# View ingress details
sudo kubectl describe ingress my-ingress

# Test internal DNS resolution
sudo kubectl exec -it <pod-name> -- nslookup app1

# View Traefik dashboard (if enabled)
sudo kubectl get svc -n kube-system traefik

# Edit resources on-the-fly
sudo kubectl edit deployment app1
sudo kubectl edit ingress my-ingress
```

---

## 🧪 Advanced Testing

### Test Ingress Path Routing

```bash
# All these should work
curl -H "Host: app1.com" http://192.168.56.110/
curl -H "Host: app1.com" http://192.168.56.110/test
curl -H "Host: app1.com" http://192.168.56.110/any/path
```

### Monitor Traffic

```bash
vagrant ssh RobrodriS

# Watch pods as requests come in
sudo kubectl logs -f -l app=app2

# Check ingress access logs (Traefik)
sudo kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
```

### Simulate Pod Failure

```bash
# Delete an app2 pod
sudo kubectl delete pod -l app=app2 --force

# K3s will automatically recreate it
sudo kubectl get pods -w
```

---

## 🧹 Cleanup

### Stop the VM

```bash
vagrant halt
```

### Destroy the Environment

```bash
vagrant destroy -f
```

### Clean Vagrant Box

```bash
vagrant box remove generic/alpine318
```

---

## 🐛 Troubleshooting

### Ingress Not Working

```bash
# Check Traefik is running
vagrant ssh RobrodriS
sudo kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Check ingress configuration
sudo kubectl describe ingress my-ingress

# Verify ingress class
sudo kubectl get ingressclass
```

### Pods Not Starting

```bash
# Check pod status
sudo kubectl get pods
sudo kubectl describe pod <pod-name>

# Check events
sudo kubectl get events --sort-by='.lastTimestamp'

# Check K3s service
sudo rc-service k3s status
sudo cat /var/log/k3s.log | tail -50
```

### Cannot Access Applications

```bash
# Verify VM network
vagrant ssh RobrodriS
ip addr show eth1  # Should show 192.168.56.110

# Test from inside VM
curl -H "Host: app1.com" http://localhost

# Check service endpoints
sudo kubectl get endpoints
```

### App2 Not Load Balancing

```bash
# Verify all 3 pods are running
sudo kubectl get pods -l app=app2

# Check service endpoints
sudo kubectl describe svc app2

# Should show 3 endpoint IPs
```

---

## 📚 References

- [K3s Documentation](https://docs.k3s.io/)
- [Traefik Ingress Controller](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Hello Kubernetes Image](https://github.com/paulbouwer/hello-kubernetes)

---

## ✨ Expected Result

A fully functional K3s environment with:

✅ Single-node K3s cluster running  
✅ 3 applications deployed (5 pods total)  
✅ Traefik Ingress Controller configured  
✅ Host-based routing working (app1.com, app2.com)  
✅ Default backend for catch-all requests (app3)  
✅ Load balancing demonstrated with app2 (3 replicas)  
✅ All resources automatically deployed via provisioning script
