# Part 3 - K3d with ArgoCD GitOps

## 📋 Description

This project implements a **K3d** cluster (K3s in Docker) with **ArgoCD** for GitOps-based continuous deployment. The setup demonstrates modern Kubernetes practices including automated deployments from a Git repository, multi-node cluster simulation, and declarative infrastructure management.

### Objective

Set up a K3d cluster running inside Docker containers with ArgoCD managing application deployments automatically from a GitHub repository, showcasing GitOps principles and continuous deployment workflows.

---

## 🏗️ Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                          Host Machine                          │
│                          192.168.56.1                          │
│                                                                │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                 VirtualBox VM (RobrodriS)                 │ │
│  │                      192.168.56.110                       │ │
│  │                                                           │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │                    Docker Engine                     │ │ │
│  │  │                                                      │ │ │
│  │  │  ┌─────────────────────────────────────────────────┐ │ │ │
│  │  │  │               K3d Cluster "core"                │ │ │ │
│  │  │  │                                                 │ │ │ │
│  │  │  │     ┌─────────────┐    ┌──────────────────┐     │ │ │ │
│  │  │  │     │ Server Node │    │   Agent Nodes    │     │ │ │ │
│  │  │  │     │   (Control  │    │   (Workers x3)   │     │ │ │ │
│  │  │  │     │    Plane)   │    │                  │     │ │ │ │
│  │  │  │     └─────────────┘    └──────────────────┘     │ │ │ │
│  │  │  │                                                 │ │ │ │
│  │  │  │     Namespaces:                                 │ │ │ │
│  │  │  │     ┌─────────────────────────────────────┐     │ │ │ │
│  │  │  │     │  argocd namespace                   │     │ │ │ │
│  │  │  │     │  ┌──────────────────────────────┐   │     │ │ │ │
│  │  │  │     │  │  ArgoCD Server & Components  │   │     │ │ │ │
│  │  │  │     │  │  - Server                    │   │     │ │ │ │
│  │  │  │     │  │  - Repo Server               │   │     │ │ │ │
│  │  │  │     │  │  - Application Controller    │   │     │ │ │ │
│  │  │  │     │  └──────────────┬───────────────┘   │     │ │ │ │
│  │  │  │     └─────────────────┼───────────────────┘     │ │ │ │
│  │  │  │                       │ GitOps Sync             │ │ │ │
│  │  │  │     ┌─────────────────▼───────────────────┐     │ │ │ │
│  │  │  │     │  dev namespace                      │     │ │ │ │
│  │  │  │     │  ┌──────────────────────────────┐   │     │ │ │ │
│  │  │  │     │  │  Application (wil42/v2)      │   │     │ │ │ │
│  │  │  │     │  │  - Deployment (1 replica)    │   │     │ │ │ │
│  │  │  │     │  │  - Service (NodePort:8888)   │   │     │ │ │ │
│  │  │  │     │  │  - Ingress (app.local)       │   │     │ │ │ │
│  │  │  │     │  └──────────────────────────────┘   │     │ │ │ │
│  │  │  │     └─────────────────────────────────────┘     │ │ │ │
│  │  │  └─────────────────────────────────────────────────┘ │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                │
│     Port Forwarding: 8888 → 8888                               │
│                                                                │
│     ┌──────────────────────┐         ┌──────────────────────┐  │
│     │   ./shared/          │         │   GitHub Repo        │  │
│     │   └─ deployments/    │◄────────│   (Source of Truth)  │  │
│     │      ├─ argo.yml     │  Syncs  │                      │  │
│     │      └─ app/         │         └──────────────────────┘  │
│     └──────────────────────┘                                   │
└────────────────────────────────────────────────────────────────┘

GitOps Flow:
1. ArgoCD Application monitors GitHub repo
2. Detects changes in p3/shared/deployments/app/
3. Automatically syncs to dev namespace
4. Self-heals if manual changes are made
```

### Components

| Component       | Type          | Namespace | Purpose                        | Port |
|-----------------|------─────────|-----------|---------───────────────────────|------|
| **K3d Cluster** | K3s in Docker | -         | Multi-node cluster simulation  | -    |
| **Server Node** | Control Plane | -         | Manages cluster state          | -    |
| **Agent Nodes** | Workers (x3)  | -         | Run workloads                  | -    |
| **ArgoCD**      | GitOps Tool   | argocd    | Continuous deployment          | 8080 |
| **Application** | Deployment    | dev       | Demo app (wil42/playground:v2) | 8888 |
| **App Service** | NodePort      | dev       | Exposes application            | 8888 |
| **App Ingress** | Ingress       | dev       | Routes traffic (app.local)     | 8888 |

---

## 📁 Project Structure

```
p3/
├── Vagrantfile                      # VM configuration
├── scripts/
│   └── server.sh                   # Automated setup script
└── shared/
    └── deployments/
        ├── argo.yml                # ArgoCD Application definition
        └── app/                    # Application manifests (synced by ArgoCD)
            ├── deployment.yml      # App deployment (wil42/playground:v2)
            ├── service.yml         # NodePort service
            └── ingress.yml         # Traefik ingress
```

---

## ⚙️ Detailed Configuration

### Vagrantfile

- **Base Box**: `generic/alpine318` (Alpine Linux 3.18)
- **Private Network**: IP `192.168.56.110`
- **Port Forwarding**: Guest `8888` → Host `8888` (for app access)
- **Resources**: 5GB RAM, 1 CPU (increased for k3d + ArgoCD)
- **Shared Folder**: `./shared` → `/vagrant_shared`

### Provisioning Script: `server.sh`

The script performs a complete automated setup:

```bash
# 1. Install Docker
apk update && apk add docker
rc-update add docker default
service docker start

# 2. Install kubectl (Kubernetes CLI)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 3. Install k3d (K3s in Docker)
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# 4. Install k9s (Kubernetes TUI - optional)
apk add k9s

# 5. Create K3d cluster with 3 agents
k3d cluster create --agents 3 core -p "8080:8888@loadbalancer"

# 6. Create namespaces
kubectl create namespace dev      # For application
kubectl create namespace argocd   # For ArgoCD

# 7. Deploy ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=600s

# 8. Set ArgoCD admin password (holasoyadmin)
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {"admin.password": "$2a$12$gbR7bIATHJekG9kAW3pt4eoTeru957RpeotGGluQ5mS50wTm5bYU2"}}'

# 9. Deploy ArgoCD Application (GitOps configuration)
kubectl apply -f /vagrant_shared/deployments/argo.yml

# 10. Wait for application to be deployed by ArgoCD
kubectl wait --for=condition=Ready pods -l app=app -n dev --timeout=600s
```

### ArgoCD Application Configuration

**argo.yml** - Defines the GitOps application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argo-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/RobertoRobrodri/Inception-of-Things.git'
    targetRevision: master
    path: p3/shared/deployments/app    # Path to app manifests
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dev
  syncPolicy:
    automated:
      prune: true        # Remove resources deleted from git
      selfHeal: true     # Undo manual changes
```

**Key features**:
- **Automated sync**: Changes in Git are automatically deployed
- **Self-healing**: Manual changes are reverted to match Git
- **Pruning**: Resources removed from Git are deleted from cluster

### Application Manifests (Managed by ArgoCD)

#### deployment.yml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
      - name: app
        image: wil42/playground:v2
        ports:
        - containerPort: 8888
```

#### service.yml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
  namespace: dev
spec:
  selector:
    app: app
  ports:
  - protocol: TCP
    port: 8888
    targetPort: 8888
  type: NodePort
```

#### ingress.yml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: dev
spec:
  ingressClassName: traefik
  rules:
  - host: app.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 8888
```

---

## 🚀 Usage

### 1. Prerequisites

- [VirtualBox](https://www.virtualbox.org/) installed
- [Vagrant](https://www.vagrantup.com/) installed
- Minimum 5GB of available RAM
- Git repository access (for ArgoCD to sync)

### 2. Start the Environment

```bash
# From the p3/ directory
vagrant up
```

**Automated process** (takes ~5-10 minutes):
1. ✅ VM creation with Alpine Linux
2. ✅ Docker installation
3. ✅ K3d cluster creation (1 server + 3 agents)
4. ✅ ArgoCD installation and configuration
5. ✅ ArgoCD Application deployment
6. ✅ Application sync from GitHub
7. ✅ Ready to use!

### 3. Access the VM

```bash
vagrant ssh RobrodriS
```

### 4. Verify Cluster and Deployment

```bash
vagrant ssh RobrodriS

# Check k3d cluster
k3d cluster list

# Check nodes
kubectl get nodes

# Check all resources
kubectl get all -A

# Check ArgoCD applications
kubectl get applications -n argocd
```

---

## ✅ Verification and Testing

### Check VM Status

```bash
vagrant status

# Expected: RobrodriS running (virtualbox)
```

### Verify K3d Cluster

```bash
vagrant ssh RobrodriS

# List k3d clusters
k3d cluster list

# Expected output:
# NAME   SERVERS   AGENTS   LOADBALANCER
# core   1/1       3/3      true

# Check Kubernetes nodes
kubectl get nodes

# Expected: 4 nodes (1 server + 3 agents) all Ready
```

### Verify ArgoCD Installation

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# All pods should be Running:
# - argocd-application-controller
# - argocd-dex-server
# - argocd-redis
# - argocd-repo-server
# - argocd-server
# - argocd-applicationset-controller

# Check ArgoCD service
kubectl get svc -n argocd
```

### Verify ArgoCD Application

```bash
# Check ArgoCD Application status
kubectl get application -n argocd

# Expected:
# NAME       SYNC STATUS   HEALTH STATUS
# argo-app   Synced        Healthy

# Describe application for details
kubectl describe application argo-app -n argocd
```

### Verify Deployed Application

```bash
# Check application resources in dev namespace
kubectl get all -n dev

# Should show:
# - deployment.apps/app
# - pod/app-xxxxx
# - service/app-service
# - ingress.networking.k8s.io/app-ingress

# Check pod status
kubectl get pods -n dev

# Check ingress
kubectl get ingress -n dev
```

### Access ArgoCD UI

**Method 1: Port-forward to ArgoCD server pod**

```bash
vagrant ssh RobrodriS

# Get ArgoCD server pod name
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server

# Port-forward (use different port if 8888 is for app)
kubectl port-forward --address 0.0.0.0 -n argocd \
  pod/<argocd-server-pod-name> 8080:8080
```

Then access from host: **https://192.168.56.110:8080**

**Credentials**:
- Username: `admin`
- Password: `holasoyadmin`

**Method 2: Port-forward to ArgoCD service**

```bash
kubectl port-forward --address 0.0.0.0 -n argocd \
  svc/argocd-server 8080:443
```

### Access the Application

**Option 1: Via port-forward**

```bash
vagrant ssh RobrodriS

# Port-forward application service
kubectl port-forward --address 0.0.0.0 -n dev \
  svc/app-service 8888:8888
```

Then from host:
```bash
curl http://192.168.56.110:8888/
# or
curl http://localhost:8888/

# Expected: {"status":"ok","message":"v2"}
```

**Option 2: Via Ingress (with host header)**

```bash
curl -H "Host: app.local" http://192.168.56.110:8888/
```

**Option 3: Using /etc/hosts**

Add to your host's `/etc/hosts`:
```
192.168.56.110 app.local
```

Then access: http://app.local:8888/

---

## 📊 Technical Information

### K3d Cluster Configuration

- **Cluster Name**: `core`
- **Server Nodes**: 1 (control plane)
- **Agent Nodes**: 3 (workers)
- **Load Balancer**: Enabled (port mapping 8080→8888)
- **Container Runtime**: Docker
- **Network**: Bridge network within Docker

### ArgoCD Configuration

- **Namespace**: `argocd`
- **Admin User**: `admin`
- **Admin Password**: `holasoyadmin` (bcrypt hash)
- **Sync Policy**: Automated with self-heal and prune
- **Git Repository**: GitHub (RobertoRobrodri/Inception-of-Things)
- **Monitored Path**: `p3/shared/deployments/app/`

### Application Configuration

- **Namespace**: `dev`
- **Image**: `wil42/playground:v2`
- **Replicas**: 1
- **Service Type**: NodePort
- **Port**: 8888
- **Ingress**: Traefik (app.local)

### Useful Commands

```bash
# K3d cluster management
k3d cluster list
k3d cluster start core
k3d cluster stop core
k3d cluster delete core

# Watch ArgoCD sync
kubectl get application -n argocd -w

# Force ArgoCD sync
kubectl patch application argo-app -n argocd \
  --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'

# View ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f

# View application logs
kubectl logs -n dev -l app=app -f

# Use k9s for interactive management (if installed)
k9s

# Check ArgoCD Application events
kubectl describe application argo-app -n argocd | grep Events -A 10

# Get ArgoCD admin password (if forgotten)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## 🧪 GitOps Workflow Testing

### Test Automated Sync

1. **Modify app image version in Git**:
   Edit `p3/shared/deployments/app/deployment.yml` in GitHub
   ```yaml
   image: wil42/playground:v3  # Change from v2 to v3
   ```

2. **Push changes to GitHub**

3. **Watch ArgoCD automatically sync**:
   ```bash
   kubectl get pods -n dev -w
   
   # You'll see the pod being recreated with new image
   ```

4. **Verify the update**:
   ```bash
   curl http://localhost:8888/
   # Response should now show v3
   ```

### Test Self-Healing

1. **Make manual change to deployment**:
   ```bash
   kubectl scale deployment app -n dev --replicas=3
   ```

2. **Watch ArgoCD revert the change**:
   ```bash
   kubectl get pods -n dev -w
   
   # ArgoCD will detect drift and revert back to 1 replica
   ```

### Test Pruning

1. **Add a new resource to Git**:
   Create a ConfigMap in the app directory

2. **Sync will deploy it automatically**

3. **Remove it from Git**:
   Delete the ConfigMap file

4. **ArgoCD will automatically delete it from cluster**

---

## 🧹 Cleanup

### Stop the Environment

```bash
vagrant halt
```

### Destroy the VM

```bash
vagrant destroy -f
```

### Clean Vagrant Box

```bash
vagrant box remove generic/alpine318
```

---

## 🐛 Troubleshooting

### K3d Cluster Not Starting

```bash
vagrant ssh RobrodriS

# Check Docker status
sudo rc-service docker status
sudo service docker start

# Check k3d logs
k3d cluster list
docker ps -a | grep k3d

# Recreate cluster
k3d cluster delete core
k3d cluster create --agents 3 core -p "8080:8888@loadbalancer"
```

### ArgoCD Pods Not Ready

```bash
# Check pod status
kubectl get pods -n argocd
kubectl describe pod <pod-name> -n argocd

# Check events
kubectl get events -n argocd --sort-by='.lastTimestamp'

# Check logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Restart ArgoCD
kubectl rollout restart deployment -n argocd
```

### ArgoCD Not Syncing Application

```bash
# Check application status
kubectl get application argo-app -n argocd -o yaml

# Check repo connection
kubectl describe application argo-app -n argocd

# Force sync
kubectl patch application argo-app -n argocd \
  --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'

# Check ArgoCD application controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f
```

### Application Not Accessible

```bash
# Verify pods are running
kubectl get pods -n dev

# Check service endpoints
kubectl get endpoints -n dev

# Test from inside cluster
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
apk add curl
curl http://app-service.dev.svc.cluster.local:8888

# Check port-forward
kubectl port-forward --address 0.0.0.0 -n dev svc/app-service 8888:8888
```

### Cannot Access ArgoCD UI

```bash
# Verify ArgoCD server is running
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server

# Port-forward directly to pod (more reliable)
POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name)
kubectl port-forward --address 0.0.0.0 -n argocd $POD 8080:8080

# Check from VM
curl -k https://localhost:8080

# Verify password hash
kubectl get secret argocd-secret -n argocd -o yaml
```

---

## 📚 References

- [K3d Documentation](https://k3d.io/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)
- [K3s Documentation](https://docs.k3s.io/)
- [wil42/playground Image](https://hub.docker.com/r/wil42/playground)

---

## ✨ Expected Result

A complete GitOps environment with:

✅ K3d cluster with 4 nodes (1 server + 3 agents)  
✅ ArgoCD installed and configured  
✅ GitOps application syncing from GitHub  
✅ Automated deployment pipeline  
✅ Self-healing capabilities (manual changes reverted)  
✅ Pruning enabled (deleted resources removed)  
✅ Application accessible via NodePort and Ingress  
✅ ArgoCD UI accessible for monitoring  
✅ Full GitOps workflow demonstration
