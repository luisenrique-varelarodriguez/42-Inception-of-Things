# Bonus - Complete CI/CD Pipeline with GitLab, ArgoCD, and Helm

## 📋 Description

This project implements a **complete DevOps pipeline** featuring GitLab for source control and CI/CD, ArgoCD for GitOps-based continuous deployment, and Helm for package management. The entire infrastructure runs on a **K3d cluster** inside Docker containers, demonstrating enterprise-grade DevOps practices in a local development environment.

### Objective

Build a production-like CI/CD pipeline showcasing modern DevOps tools and practices:
- **GitLab**: Internal Git repository and CI/CD platform
- **ArgoCD**: GitOps continuous deployment
- **Helm**: Kubernetes package manager
- **K3d**: Lightweight multi-node Kubernetes cluster
- **Automated deployment**: Changes in Git trigger automatic deployments

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                           Host Machine                               │
│                           192.168.56.1                               │
│                                                                      │
│   Ports: 18081 (ArgoCD) | 18082 (GitLab) | 18083 (App)               │
│               ▲                 ▲                 ▲                  │
│               │                 │                 │                  │
│  ┌────────────┼─────────────────┼─────────────────┼───────────────┐  │
│  │  VM        │                 │                 │               │  │
│  │  LvarelaS  │ Port Forwards:  │                 │               │  │
│  │            │ 8081→18081      │ 8082→18082      │ 8083→18083    │  │
│  │            │                 │                 │               │  │
│  │  ┌─────────┴─────────────────┴─────────────────┴────────────┐  │  │
│  │  │                      Docker Engine                       │  │  │
│  │  │                                                          │  │  │
│  │  │  ┌────────────────────────────────────────────────────┐  │  │  │
│  │  │  │            K3d Cluster "dev-cluster"               │  │  │  │
│  │  │  │            (1 Server + 3 Agent Nodes)              │  │  │  │
│  │  │  │                                                    │  │  │  │
│  │  │  │  Namespaces:                                       │  │  │  │
│  │  │  │                                                    │  │  │  │
│  │  │  │  ┌──────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │  gitlab namespace                            │  │  │  │  │
│  │  │  │  │  ┌────────────────────────────────────────┐  │  │  │  │  │
│  │  │  │  │  │  GitLab Components                     │  │  │  │  │  │
│  │  │  │  │  │  - Webservice (UI/API)                 │  │  │  │  │  │
│  │  │  │  │  │  - Shell (Git SSH)                     │  │  │  │  │  │
│  │  │  │  │  │  - Gitaly (Git storage)                │  │  │  │  │  │
│  │  │  │  │  │  - Sidekiq (background jobs)           │  │  │  │  │  │
│  │  │  │  │  │  - PostgreSQL (database)               │  │  │  │  │  │
│  │  │  │  │  │  - Redis (cache)                       │  │  │  │  │  │
│  │  │  │  │  └────────────────────────────────────────┘  │  │  │  │  │
│  │  │  │  └──────────────────────────────────────────────┘  │  │  │  │
│  │  │  │                                                    │  │  │  │
│  │  │  │  ┌──────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │  argocd namespace                            │  │  │  │  │
│  │  │  │  │  ┌────────────────────────────────────────┐  │  │  │  │  │
│  │  │  │  │  │  ArgoCD Components                     │  │  │  │  │  │
│  │  │  │  │  │  - Server (UI/API)                     │  │  │  │  │  │
│  │  │  │  │  │  - Repo Server (Git sync)              │  │  │  │  │  │
│  │  │  │  │  │  - Application Controller              │  │  │  │  │  │
│  │  │  │  │  │  - Redis (cache)                       │  │  │  │  │  │
│  │  │  │  │  └──────────┬─────────────────────────────┘  │  │  │  │  │
│  │  │  │  └─────────────┼────────────────────────────────┘  │  │  │  │
│  │  │  │                │                                   │  │  │  │
│  │  │  │                │ Monitors GitLab repo              │  │  │  │
│  │  │  │                │ Syncs Helm chart                  │  │  │  │
│  │  │  │                │                                   │  │  │  │
│  │  │  │  ┌─────────────▼────────────────────────────────┐  │  │  │  │
│  │  │  │  │  dev namespace                               │  │  │  │  │
│  │  │  │  │  ┌────────────────────────────────────────┐  │  │  │  │  │
│  │  │  │  │  │  wil42 Application (Helm Chart)        │  │  │  │  │  │
│  │  │  │  │  │  - Deployment (wil42/playground:v2)    │  │  │  │  │  │
│  │  │  │  │  │  - Service (ClusterIP:8888)            │  │  │  │  │  │
│  │  │  │  │  │  - Ingress (Traefik)                   │  │  │  │  │  │
│  │  │  │  │  └────────────────────────────────────────┘  │  │  │  │  │
│  │  │  │  └──────────────────────────────────────────────┘  │  │  │  │
│  │  │  └────────────────────────────────────────────────────┘  │  │  │
│  │  └──────────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│     ┌──────────────────┐                 ┌────────────────────┐      │
│     │  ./confs/        │                 │  GitLab Repo       │      │
│     │  ├─ charts/      │─── pushed to ──▶│  (Internal)        │      │
│     │  ├─ argocd/      │                 │                    │      │
│     │  └─ helm-values/ │                 └──────────┬─────────┘      │
│     └──────────────────┘                            │                │
│                                                     │                │
│                                            ┌────────▼──────────┐     │
│                                            │  ArgoCD watches   │     │
│                                            │  and auto-syncs   │     │
│                                            └───────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘

CI/CD Flow:
1. Developer pushes code to GitLab repository
2. GitLab stores the Helm chart (bonus/confs/charts/wil42/)
3. ArgoCD monitors GitLab for changes
4. ArgoCD automatically syncs and deploys to dev namespace
5. Self-healing: Manual changes are reverted
6. Pruning: Deleted resources are removed
```

### Components

| Component       | Type            | Namespace   | Purpose                        | Port/Access |
|-----------------|-----------------|-------------|--------------------------------|-------------|
| **K3d Cluster** | K3s in Docker   | -           | Multi-node Kubernetes          | -           |
| **GitLab**      | Git + CI/CD     | gitlab      | Source control, CI/CD platform | 18082       |
| **ArgoCD**      | GitOps Tool     | argocd      | Continuous deployment          | 18081       |
| **wil42 App**   | Helm Chart      | dev         | Demo application               | 18083       |
| **Helm**        | Package Manager | -           | Chart deployment               | -           |
| **Traefik**     | Ingress         | kube-system | Load balancing & routing       | -           |

---

## 📁 Project Structure

```
bonus/
├── Vagrantfile                          # VM configuration (10GB RAM, 6 CPUs)
├── README.md                            # Documentation
├── scripts/
│   ├── run.sh                          # Main orchestrator script
│   ├── 00_requirements.sh              # Docker, kubectl, k3d, helm
│   ├── 10_k3d_cluster.sh               # K3d cluster creation
│   ├── 20_helm.sh                      # Helm installation
│   ├── 30_argocd.sh                    # ArgoCD deployment via Helm
│   ├── 40_gitlab.sh                    # GitLab deployment via Helm
│   ├── 50_app_chart.sh                 # ArgoCD Application setup
│   ├── 60_port_forward.sh              # Resilient port-forwarding
│   └── logging.sh                      # Colored logging functions
└── confs/
    ├── helm-values/
    │   └── argocd-values.yaml          # ArgoCD Helm values
    ├── argocd/
    │   └── wil42-app.yaml              # ArgoCD Application definition
    └── charts/
        └── wil42/                      # Application Helm chart
            ├── Chart.yaml              # Chart metadata
            ├── values.yaml             # Chart values (image: v2)
            └── templates/
                ├── deployment.yaml     # K8s deployment
                ├── service.yaml        # K8s service
                ├── ingress.yaml        # K8s ingress
                └── NOTES.txt           # Post-install notes
```

---

## ⚙️ Detailed Configuration

### Vagrantfile

- **Base Box**: `generic/alpine318` (Alpine Linux 3.18)
- **VM Name**: `LvarelaS`
- **Private Network**: IP `192.168.56.110`
- **Resources**: **10GB RAM**, **6 CPUs** (required for GitLab)
- **Port Forwarding**:
  - `18081` → ArgoCD UI
  - `18082` → GitLab UI  
  - `18083` → Application
- **Shared Folder**: `.` → `/shared` (project root)

### Automated Setup Scripts

#### `run.sh` - Main Orchestrator
Executes all setup scripts in sequence:
1. Prerequisites (Docker, kubectl, k3d, helm)
2. K3d cluster creation
3. Helm installation
4. ArgoCD deployment
5. GitLab deployment
6. Application chart configuration
7. Port-forwarding setup
8. Pauses for manual GitLab configuration

#### `00_requirements.sh` - Prerequisites
```bash
# Installs:
- bash, curl, tar, git, sudo
- Docker (with auto-start)
- kubectl (latest stable + alias 'k')
- k3d (K3s in Docker)
- k9s (Kubernetes TUI)
```

#### `10_k3d_cluster.sh` - Cluster Creation
```bash
# Creates K3d cluster with:
- Cluster name: "dev-cluster"
- 1 server node (control plane)
- 3 agent nodes (workers)
- Port mapping: 8080→8888 (loadbalancer)
- 30-second wait for stability
```

#### `20_helm.sh` - Helm Installation
```bash
# Installs Helm package manager
# Used for deploying ArgoCD and GitLab
```

#### `30_argocd.sh` - ArgoCD Deployment
```bash
# Deploys ArgoCD via Helm chart
# Uses custom values from confs/helm-values/argocd-values.yaml
# Sets admin password: "holasoyadmin"
# Waits up to 10 minutes for readiness
```

#### `40_gitlab.sh` - GitLab Deployment
```bash
# Deploys GitLab via Helm chart
# Uses minikube-minimum values (k3d optimized)
# Configures:
  - Domain: localhost
  - HTTP only (no HTTPS)
  - Restart policies for reliability
# Waits up to 20 minutes for readiness
# Extracts initial root password
```

#### `50_app_chart.sh` - Application Setup
```bash
# Creates dev namespace
# Deploys ArgoCD Application (wil42-app.yaml)
# Configures:
  - Source: GitLab internal repo
  - Path: bonus/confs/charts/wil42
  - Helm chart with values.yaml
  - Auto-sync + self-heal + prune
```

#### `60_port_forward.sh` - Port Forwarding
```bash
# Sets up resilient port-forwards in background:
- ArgoCD:  8081 → argocd-server:443
- GitLab:  8082 → gitlab-webservice:8181
- App:     8083 → wil42-service:8888
# Uses nohup for persistence
# Auto-restarts on failure
```

### ArgoCD Application Configuration

**wil42-app.yaml**:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil42
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/inception-of-things.git"
    targetRevision: master
    path: bonus/confs/charts/wil42
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**Key features**:
- Monitors **internal GitLab repository**
- Uses **Helm chart** from `bonus/confs/charts/wil42/`
- **Automated sync**: Changes trigger deployments
- **Self-healing**: Manual changes reverted
- **Pruning**: Deleted resources removed

### Helm Chart: wil42

**Chart.yaml**:
```yaml
apiVersion: v2
name: wil42
description: "Simple wil42 app chart"
type: application
version: 0.1.0
appVersion: "v1"
```

**values.yaml**:
```yaml
image:
  tag: "v2"  # Application version
```

**Templates**:
- `deployment.yaml`: Creates pods with wil42/playground:v2
- `service.yaml`: Exposes on port 8888
- `ingress.yaml`: Traefik routing
- `NOTES.txt`: Post-install instructions

---

## 🚀 Usage

### 1. Prerequisites

- [VirtualBox](https://www.virtualbox.org/) installed
- [Vagrant](https://www.vagrantup.com/) installed
- **Minimum 10GB of available RAM** (GitLab is resource-intensive)
- Ports **18081, 18082, 18083** free on host machine
- Git installed on host machine

### 2. Start the Automated Setup

```bash
cd bonus/
vagrant up
```

**Expected duration**: 15-20 minutes

**What happens**:
1. ✅ VM creation with 10GB RAM
2. ✅ Prerequisites installation
3. ✅ K3d cluster with 4 nodes
4. ✅ Helm installation
5. ✅ ArgoCD deployment
6. ✅ GitLab deployment (takes longest ~10 min)
7. ✅ Application chart configuration
8. ✅ Port-forwarding setup
9. ⏸️ **Pauses** waiting for manual GitLab repository setup

### 3. Configure GitLab (Manual Step)

The setup will pause with instructions. Follow these steps:

#### Step 3.1: Get GitLab Password

```bash
# From another terminal (while vagrant up is paused)
cd bonus/
vagrant ssh

# Inside VM, get GitLab root password
kubectl get secret gitlab-gitlab-initial-root-password \
  -n gitlab -o jsonpath='{.data.password}' | base64 -d

# Note the password and exit
exit
```

#### Step 3.2: Access GitLab UI

- URL: **http://localhost:18082**
- Username: `root`
- Password: (from previous step)

#### Step 3.3: Create Project in GitLab

1. Click **"New project"** → **"Create blank project"**
2. Project name: **`inception-of-things`** (must match exactly, lowercase)
3. Project slug: **`inception-of-things`**
4. Visibility: **Public** ✅ (important!)
5. Initialize with README: **No**
6. Click **"Create project"**

#### Step 3.4: Push Repository to GitLab

From your **host machine** (Mac):

```bash
# Navigate to project directory
cd /Users/cx02923/Desktop/42/42-Inception-of-Things

# Get GitLab password again (if needed)
# Use the password from Step 3.1

# Add GitLab remote
git remote remove gitlab 2>/dev/null || true  # Remove if exists
git remote add gitlab http://root:PASSWORD@localhost:18082/root/inception-of-things.git

# Push all branches
git push gitlab --all

# Push tags (optional)
git push gitlab --tags
```

**Replace `PASSWORD`** with the actual GitLab root password.

### 4. Verify Deployment

After pushing to GitLab, ArgoCD will automatically detect and deploy the application.

#### Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **ArgoCD** | http://localhost:18081 | admin / holasoyadmin |
| **GitLab** | http://localhost:18082 | root / (see Step 3.1) |
| **Application** | http://localhost:18083 | - |

#### Check ArgoCD Sync

1. Open **http://localhost:18081**
2. Login with `admin` / `holasoyadmin`
3. You should see the **"wil42"** application
4. Status should show:
   - Sync Status: **Synced** ✅
   - Health: **Healthy** ✅

#### Test Application

```bash
# From host machine
curl http://localhost:18083/

# Expected response:
# {"status":"ok","message":"v2"}
```

---

## ✅ Verification and Testing

### Check VM Status

```bash
vagrant status

# Expected: LvarelaS running (virtualbox)
```

### Verify K3d Cluster

```bash
vagrant ssh

# List clusters
k3d cluster list

# Expected:
# NAME          SERVERS   AGENTS   LOADBALANCER
# dev-cluster   1/1       3/3      true

# Check nodes
kubectl get nodes

# Expected: 4 nodes all Ready
```

### Verify All Namespaces and Pods

```bash
kubectl get all -A

# Should show pods running in:
# - kube-system (traefik, coredns, etc.)
# - argocd (argocd-server, argocd-repo-server, etc.)
# - gitlab (gitlab-webservice, gitlab-gitaly, postgresql, redis, etc.)
# - dev (wil42 application pods)
```

### Verify GitLab

```bash
# Check GitLab pods
kubectl get pods -n gitlab

# All should be Running
# Key pods:
# - gitlab-webservice-default
# - gitlab-gitaly
# - gitlab-postgresql
# - gitlab-redis-master

# Check GitLab service
kubectl get svc -n gitlab
```

### Verify ArgoCD

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# All should be Running

# Check ArgoCD applications
kubectl get application -n argocd

# Should show:
# NAME    SYNC STATUS   HEALTH STATUS
# wil42   Synced        Healthy
```

### Verify Application Deployment

```bash
# Check dev namespace
kubectl get all -n dev

# Should show:
# - deployment.apps/wil42
# - replicaset.apps/wil42-xxxxx
# - pod/wil42-xxxxx
# - service/wil42-service
# - ingress.networking.k8s.io/wil42-ingress

# Check pod logs
kubectl logs -n dev -l app.kubernetes.io/name=wil42
```

### Verify Port Forwards

```bash
# Check port-forward processes
ps aux | grep 'kubectl port-forward'

# Should show 3 processes for ArgoCD, GitLab, and App
```

---

## 📊 Technical Information

### Resource Requirements

- **RAM**: 10GB minimum
  - GitLab: ~6GB
  - K3d cluster: ~2GB
  - ArgoCD: ~1GB
  - System overhead: ~1GB
- **CPU**: 6 cores recommended
- **Disk**: ~15GB for images and data

### Network Architecture

- **VM Private Network**: `192.168.56.110`
- **K3d Internal Network**: Docker bridge
- **Service Mesh**: Traefik (bundled with K3s)
- **Internal DNS**: CoreDNS (cluster DNS resolution)

### GitLab Configuration

- **Deployment**: Minimal configuration for k3d
- **Components**:
  - Webservice: HTTP API and UI
  - Gitaly: Git repository storage
  - PostgreSQL: Database
  - Redis: Cache and queues
  - Sidekiq: Background jobs
- **Storage**: Persistent volumes in k3d
- **Access**: Internal (cluster) + External (port-forward)

### ArgoCD Configuration

- **Deployment**: Helm chart with custom values
- **Admin Password**: `holasoyadmin` (bcrypt)
- **Repository**: Internal GitLab
- **Sync Policy**: Automated, self-heal, prune
- **Sync Interval**: ~3 minutes (default)

### Useful Commands

```bash
# K3d cluster management
k3d cluster list
k3d cluster stop dev-cluster
k3d cluster start dev-cluster
k3d cluster delete dev-cluster

# Helm releases
helm list -A

# GitLab password recovery
kubectl get secret gitlab-gitlab-initial-root-password \
  -n gitlab -o jsonpath='{.data.password}' | base64 -d

# Force ArgoCD sync
kubectl patch application wil42 -n argocd \
  --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'

# Watch ArgoCD application status
kubectl get application -n argocd -w

# View all ArgoCD applications details
kubectl describe application -n argocd

# Restart port-forwards
vagrant ssh
sh /shared/scripts/60_port_forward.sh

# Use k9s for interactive management
k9s

# Check resource usage
kubectl top nodes
kubectl top pods -A
```

---

## 🧪 CI/CD Workflow Testing

### Test 1: Modify Application Version

1. **Edit the Helm chart values**:
   ```bash
   # On host machine
   cd bonus/confs/charts/wil42/
   nano values.yaml
   
   # Change:
   image:
     tag: "v3"  # Change from v2 to v3
   ```

2. **Commit and push**:
   ```bash
   git add values.yaml
   git commit -m "Update app to v3"
   git push gitlab master
   ```

3. **Watch ArgoCD auto-sync**:
   - Open ArgoCD UI: http://localhost:18081
   - Watch the wil42 application
   - It will detect the change and sync automatically
   - Pod will be recreated with new image

4. **Verify the change**:
   ```bash
   curl http://localhost:18083/
   # Should now return: {"status":"ok","message":"v3"}
   ```

### Test 2: Self-Healing

1. **Make manual change**:
   ```bash
   vagrant ssh
   kubectl scale deployment wil42 -n dev --replicas=3
   ```

2. **Watch ArgoCD revert**:
   ```bash
   kubectl get pods -n dev -w
   # ArgoCD will detect drift and revert to 1 replica
   ```

### Test 3: Add New Resource

1. **Create ConfigMap in Helm chart**:
   ```yaml
   # bonus/confs/charts/wil42/templates/configmap.yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: wil42-config
   data:
     greeting: "Hello from wil42!"
   ```

2. **Commit and push**:
   ```bash
   git add configmap.yaml
   git commit -m "Add ConfigMap"
   git push gitlab master
   ```

3. **Verify automatic deployment**:
   ```bash
   kubectl get configmap -n dev
   # ConfigMap will appear automatically
   ```

### Test 4: Pruning

1. **Delete resource from Git**:
   ```bash
   git rm bonus/confs/charts/wil42/templates/configmap.yaml
   git commit -m "Remove ConfigMap"
   git push gitlab master
   ```

2. **Verify automatic removal**:
   ```bash
   kubectl get configmap -n dev
   # ConfigMap will be deleted automatically
   ```

---

## 🧹 Cleanup

### Stop Services

```bash
# Stop VM (preserves state)
vagrant halt

# Can resume later with:
vagrant up
```

### Destroy Environment

```bash
# Complete cleanup
vagrant destroy -f

# This removes:
# - VM and all data
# - K3d cluster
# - All deployments
# - Port forwards
```

### Clean Vagrant Box

```bash
vagrant box remove generic/alpine318
```

### Clean Docker Images (Optional)

If you want to free up space on your host:

```bash
# Remove all unused Docker images
docker system prune -a

# Warning: This removes ALL unused images, not just from this project
```

---

## 🐛 Troubleshooting

### GitLab Not Starting

```bash
vagrant ssh

# Check GitLab pods
kubectl get pods -n gitlab

# Check specific pod logs
kubectl logs -n gitlab gitlab-webservice-default-xxxxx

# Common issue: Insufficient resources
# Solution: Ensure VM has 10GB RAM

# Restart GitLab
kubectl rollout restart deployment -n gitlab
```

### ArgoCD Not Syncing

```bash
# Check application status
kubectl describe application wil42 -n argocd

# Check ArgoCD can reach GitLab
kubectl exec -it -n argocd argocd-repo-server-xxxxx -- sh
curl http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/inception-of-things.git

# Force refresh
kubectl patch application wil42 -n argocd \
  --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f
```

### Cannot Access Services on Host

```bash
vagrant ssh

# Check port-forwards are running
ps aux | grep 'kubectl port-forward'

# If not running, restart them
sh /shared/scripts/60_port_forward.sh

# Test from inside VM
curl http://localhost:8081  # ArgoCD
curl http://localhost:8082  # GitLab
curl http://localhost:8083  # App

# If working from VM but not host, check Vagrantfile port forwarding
```

### Application Pods Not Starting

```bash
# Check pod status
kubectl get pods -n dev
kubectl describe pod wil42-xxxxx -n dev

# Check if image can be pulled
kubectl get events -n dev --sort-by='.lastTimestamp'

# Check ArgoCD sync status
kubectl get application wil42 -n argocd -o yaml

# Manual sync
argocd app sync wil42 --grpc-web
```

### Out of Memory Issues

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -A

# If GitLab is consuming too much:
# 1. Increase VM RAM in Vagrantfile (to 12GB)
# 2. Restart VM
vagrant reload
```

### Repository Not Found in GitLab

```bash
# Verify project exists
# Access http://localhost:18082 and check

# Verify project name is correct
# Must be: root/inception-of-things

# Check ArgoCD repo URL
kubectl get application wil42 -n argocd -o yaml | grep repoURL

# Should be:
# http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/inception-of-things.git
```

---

## 📚 References

- [K3d Documentation](https://k3d.io/)
- [GitLab Helm Charts](https://docs.gitlab.com/charts/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [GitOps Principles](https://opengitops.dev/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

## ✨ Expected Result

A complete enterprise-grade CI/CD pipeline with:

✅ K3d cluster with 4 nodes running in Docker  
✅ GitLab fully deployed with web UI accessible  
✅ ArgoCD monitoring GitLab repository  
✅ Helm charts managed and deployed  
✅ Automated CI/CD pipeline:
  - Push to GitLab → ArgoCD detects → Auto-deploy  
✅ GitOps features working:
  - Automated sync ✅
  - Self-healing ✅
  - Pruning ✅  
✅ Application accessible via browser  
✅ Full DevOps workflow demonstration  
✅ Production-like environment in local setup
2. **Changes**: Modify tag in the chart and push to see GitOps in action  
3. **Port-forwards**: Remain active automatically even if the app is redeployed
4. **Branch**: Make sure you're working on the `master` branch

## DevOps Flow

1. **Developer push** → GitLab receives the code
2. **ArgoCD polling** → Detects changes every 3 minutes (or manual sync)
3. **Auto-sync** → Automatically deploys using Helm
4. **Resilient port-forwards** → Maintain connectivity during redeployments
5. **Monitoring** → ArgoCD monitors application state

### Change application version:
1. Modify `image.tag` in `confs/charts/wil42/values.yaml`
2. Push to internal GitLab on `master` branch
3. Wait 3 minutes or do manual sync in ArgoCD
4. See the new version deployed automatically

## Troubleshooting

### If GitLab doesn't start:
```bash
vagrant ssh
kubectl -n gitlab get pods
kubectl -n gitlab logs deployment/gitlab-webservice-default
```

### If ArgoCD can't access the repo:
- Verify that the GitLab project is **public**
- The repo URL should be: `http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/inception-of-things.git`

### If port-forwards don't work:
```bash
vagrant ssh
cd /shared
pkill kubectl  # Stop existing port-forwards
./scripts/60_port_forward.sh  # Restart port-forwards
```

### If the application doesn't deploy:
1. Verify that the repository is uploaded correctly
2. Check Application in ArgoCD UI
3. Do manual sync if necessary

## Cleanup

```bash
vagrant destroy -f
```

## Technical Features

- **OS**: Alpine Linux 3.18
- **Kubernetes**: k3d (k3s in Docker)
- **Container Runtime**: Docker
- **Ingress**: Traefik (included in k3s)
- **Storage**: Local path provisioner
- **DNS**: CoreDNS
- **GitOps**: ArgoCD with polling every 3 minutes
- **Port-forwarding**: Resilient with auto-reconnection

## Implementation Notes

- Idempotent scripts (safe to re-run)
- Resilient port-forwards against redeployments
- Minimal configuration for demo/development
- No persistence (data is lost when destroying VM)
- Optimized for complete GitOps workflow