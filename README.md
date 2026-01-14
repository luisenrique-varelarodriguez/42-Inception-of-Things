# Inception-of-Things (IoT)

<div align="center">

**A comprehensive guide to Kubernetes, K3s, K3d, GitOps, and DevOps practices**

[![42 Project](https://img.shields.io/badge/42-Project-00babc?style=flat-square&logo=42)](https://42.fr)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![K3s](https://img.shields.io/badge/K3s-FFC61C?style=flat-square&logo=k3s&logoColor=black)](https://k3s.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat-square&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![GitLab](https://img.shields.io/badge/GitLab-FC6D26?style=flat-square&logo=gitlab&logoColor=white)](https://gitlab.com/)

</div>

---

## 📚 Table of Contents

- [About the Project](#-about-the-project)
- [Architecture Overview](#-architecture-overview)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Parts Overview](#-parts-overview)
  - [Part 1: K3s Cluster](#part-1-k3s-cluster)
  - [Part 2: K3s with Applications](#part-2-k3s-with-applications)
  - [Part 3: K3d with ArgoCD](#part-3-k3d-with-argocd)
  - [Bonus: Complete CI/CD Pipeline](#bonus-complete-cicd-pipeline)
- [Learning Path](#-learning-path)
- [Technologies Used](#-technologies-used)
- [Resources](#-resources)
- [Contributing](#-contributing)

---

## 🎯 About the Project

**Inception-of-Things** is a comprehensive educational project that explores modern Kubernetes deployment strategies, GitOps practices, and DevOps automation. The project is structured in progressive parts, each building upon the previous one to demonstrate increasingly complex Kubernetes concepts.

### What You'll Learn

- 🐳 **Container orchestration** with Kubernetes
- 🚀 **Lightweight Kubernetes** with K3s and K3d
- 🔄 **GitOps principles** with ArgoCD
- 📦 **Package management** with Helm
- 🏗️ **Infrastructure as Code** with Vagrant
- 🔧 **CI/CD pipelines** with GitLab
- 🌐 **Ingress controllers** and routing with Traefik
- 🔐 **Service mesh** and networking concepts

---

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                    Inception-of-Things Project                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────┐   ┌────────────┐   ┌──────────┐   ┌────────────────┐   │
│  │  Part 1  │   │   Part 2   │   │  Part 3  │   │      Bonus     │   │
│  │          │   │            │   │          │   │                │   │
│  │    K3s   │ → │    K3s     │ → │   K3d    │ → │   K3d          │   │
│  │  Cluster │   │  + Apps    │   │ + ArgoCD │   │ + GitLab CI/CD │   │
│  │          │   │  + Ingress │   │ + GitOps │   │ + Helm         │   │
│  └──────────┘   └────────────┘   └──────────┘   └────────────────┘   │
│                                                                      │
│  Complexity:  ▰▱▱▱▱         ▰▰▱▱▱         ▰▰▰▱▱         ▰▰▰▰▰        │
│  Time:        ~10 min       ~10 min       ~10 min       ~20 min      │
│  RAM:         4GB           4GB           5GB           10GB         │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
42-Inception-of-Things/
│
├── README.md                   # This file - Project overview
│
├── p1/                         # Part 1: Basic K3s Cluster
│   ├── Vagrantfile             # 2 VMs: 1 server + 1 worker
│   ├── README.md               # Detailed documentation
│   └── scripts/
│       ├── server.sh           # K3s server setup
│       └── worker.sh           # K3s worker setup
│
├── p2/                         # Part 2: K3s with Apps & Ingress
│   ├── Vagrantfile             # 1 VM: single node
│   ├── README.md               # Detailed documentation
│   ├── scripts/
│   │   └── server.sh           # K3s + apps setup
│   └── shared/
│       ├── deployments/        # App deployments (app1, app2, app3)
│       ├── services/           # ClusterIP services
│       └── ingress/            # Traefik ingress rules
│
├── p3/                         # Part 3: K3d with ArgoCD
│   ├── Vagrantfile             # 1 VM: K3d cluster
│   ├── README.md               # Detailed documentation
│   ├── scripts/
│   │   └── server.sh           # K3d + ArgoCD setup
│   └── shared/
│       └── deployments/
│           ├── argo.yml        # ArgoCD Application
│           └── app/            # App manifests (synced by ArgoCD)
│
└── bonus/                      # Bonus: Full CI/CD Pipeline
    ├── Vagrantfile             # 1 VM: Complete DevOps environment
    ├── README.md               # Detailed documentation
    ├── scripts/                # Automated setup scripts
    │   ├── run.sh              # Main orchestrator
    │   ├── 00_requirements.sh  # Prerequisites
    │   ├── 10_k3d_cluster.sh   # Cluster creation
    │   ├── 20_helm.sh          # Helm installation
    │   ├── 30_argocd.sh        # ArgoCD deployment
    │   ├── 40_gitlab.sh        # GitLab deployment
    │   ├── 50_app_chart.sh     # App chart setup
    │   └── 60_port_forward.sh  # Port forwarding
    └── confs/
        ├── charts/             # Helm charts
        ├── argocd/             # ArgoCD configs
        └── helm-values/        # Helm values
```

---

## ✅ Prerequisites

### Required Software

- **[VirtualBox](https://www.virtualbox.org/)** - Virtualization platform
- **[Vagrant](https://www.vagrantup.com/)** - VM management tool
- **Git** - Version control

### System Requirements

| Part       | RAM  | CPU     | Disk Space | Duration |
|------------|------|---------|------------|----------|
| **Part 1** | 4GB  | 2 cores | 5GB        | ~10 min  |
| **Part 2** | 4GB  | 2 cores | 5GB        | ~10 min  |
| **Part 3** | 5GB  | 2 cores | 8GB        | ~10 min  |
| **Bonus**  | 10GB | 6 cores | 15GB       | ~20 min  |

### Installation

**macOS:**
```bash
# Using Homebrew
brew install --cask virtualbox vagrant

# Or download from official websites
```

**Linux:**
```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install virtualbox vagrant

# Arch Linux
sudo pacman -S virtualbox vagrant
```

**Windows:**
- Download installers from official websites
- Enable Hyper-V if needed

---

## 🚀 Getting Started

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/Inception-of-Things.git
   cd Inception-of-Things
   ```

2. **Choose a part** and navigate to its directory:
   ```bash
   cd p1  # or p2, p3, bonus
   ```

3. **Read the documentation:**
   ```bash
   cat README.md  # Each part has detailed instructions
   ```

4. **Start the environment:**
   ```bash
   vagrant up
   ```

5. **Access the VM:**
   ```bash
   vagrant ssh
   ```

6. **Clean up when done:**
   ```bash
   vagrant destroy -f
   ```

---

## 📖 Parts Overview

### Part 1: K3s Cluster

<details>
<summary>Click to expand</summary>

#### Overview
Create a basic two-node K3s cluster with one server (control plane) and one worker node.

#### What You'll Learn
- K3s installation and configuration
- Multi-node cluster setup
- Node communication via private network
- Token-based authentication
- Basic cluster operations

#### Architecture
- **2 VMs**: `RobrodriS` (server) + `RobrodriSW` (worker)
- **Network**: Private network `192.168.56.0/24`
- **K3s Version**: Latest stable
- **CNI**: Flannel

#### Quick Start
```bash
cd p1
vagrant up
vagrant ssh RobrodriS
sudo kubectl get nodes
```

#### Key Concepts
- ✅ Control plane vs worker nodes
- ✅ K3s lightweight architecture
- ✅ Cluster networking
- ✅ Node management

📚 **[Full Documentation](p1/README.md)**

</details>

---

### Part 2: K3s with Applications

<details>
<summary>Click to expand</summary>

#### Overview
Deploy a single-node K3s cluster with multiple applications and an Ingress controller for routing.

#### What You'll Learn
- Kubernetes deployments and services
- Ingress controller (Traefik)
- Host-based routing
- Application scaling
- Service discovery

#### Architecture
- **1 VM**: `RobrodriS` (all-in-one)
- **3 Applications**: app1, app2 (3 replicas), app3
- **Ingress**: Traefik with host-based routing
- **Services**: ClusterIP

#### Quick Start
```bash
cd p2
vagrant up
curl -H "Host: app1.com" http://192.168.56.110/
curl -H "Host: app2.com" http://192.168.56.110/
curl http://192.168.56.110/  # app3 (default)
```

#### Key Concepts
- ✅ Kubernetes deployments
- ✅ ClusterIP services
- ✅ Ingress routing
- ✅ Load balancing
- ✅ Horizontal scaling

📚 **[Full Documentation](p2/README.md)**

</details>

---

### Part 3: K3d with ArgoCD

<details>
<summary>Click to expand</summary>

#### Overview
Set up a K3d cluster (K3s in Docker) with ArgoCD for GitOps-based continuous deployment.

#### What You'll Learn
- K3d cluster management
- GitOps principles
- ArgoCD installation and configuration
- Automated deployments from Git
- Self-healing and pruning

#### Architecture
- **1 VM** with Docker
- **K3d Cluster**: 1 server + 3 agents
- **ArgoCD**: GitOps controller
- **Git Source**: GitHub repository
- **Application**: Automatically deployed and synced

#### Quick Start
```bash
cd p3
vagrant up

# Access ArgoCD
open http://localhost:8888  # After port-forwarding
# Username: admin
# Password: holasoyadmin

# Access Application
curl http://localhost:8888/  # After port-forwarding
```

#### Key Concepts
- ✅ K3d (K3s in Docker)
- ✅ GitOps methodology
- ✅ ArgoCD application management
- ✅ Automated sync
- ✅ Self-healing capabilities
- ✅ Declarative deployments

📚 **[Full Documentation](p3/README.md)**

</details>

---

### Bonus: Complete CI/CD Pipeline

<details>
<summary>Click to expand</summary>

#### Overview
Build a complete DevOps pipeline with GitLab for CI/CD, ArgoCD for GitOps, and Helm for package management.

#### What You'll Learn
- GitLab installation and configuration
- Helm charts creation and management
- Complete CI/CD pipeline
- Internal Git repositories
- ArgoCD with Helm
- Production-like DevOps environment

#### Architecture
- **1 VM** (10GB RAM, 6 CPUs)
- **K3d Cluster**: 1 server + 3 agents
- **GitLab**: Internal Git + CI/CD
- **ArgoCD**: GitOps controller
- **Helm**: Package manager
- **Application**: Helm chart deployed via GitOps

#### Quick Start
```bash
cd bonus
vagrant up

# Wait for setup to pause (~15 min)
# Follow on-screen instructions to:
# 1. Access GitLab
# 2. Create project
# 3. Push repository

# Access services:
# - ArgoCD:  http://localhost:18081
# - GitLab:  http://localhost:18082
# - App:     http://localhost:18083
```

#### Key Concepts
- ✅ GitLab deployment
- ✅ Helm charts
- ✅ Complete CI/CD pipeline
- ✅ Internal Git repositories
- ✅ ArgoCD with Helm integration
- ✅ Automated deployments
- ✅ Enterprise-grade DevOps

#### Credentials
- **ArgoCD**: admin / holasoyadmin
- **GitLab**: root / (see logs)

📚 **[Full Documentation](bonus/README.md)**

</details>

---

## 🎓 Learning Path

### Recommended Order

```
1️⃣ Part 1: K3s Cluster
   └─ Understand basic Kubernetes cluster setup
   └─ Learn node communication
   └─ Master kubectl basics

2️⃣ Part 2: K3s with Applications
   └─ Deploy applications to Kubernetes
   └─ Configure ingress routing
   └─ Understand services and load balancing

3️⃣ Part 3: K3d with ArgoCD
   └─ Learn GitOps principles
   └─ Master ArgoCD
   └─ Implement continuous deployment

4️⃣ Bonus: Complete CI/CD Pipeline
   └─ Integrate all concepts
   └─ Build production-like environment
   └─ Master Helm and GitLab
```

### Key Takeaways by Part

| Part      | Key Skill              | Real-World Application         |
|-----------|------------------------|--------------------------------|
| **P1**    | Cluster Management     | Multi-node production clusters |
| **P2**    | Application Deployment | Microservices architecture     |
| **P3**    | GitOps                 | Automated deployments          |
| **Bonus** | Full DevOps Pipeline   | Enterprise CI/CD               |

---

## 🛠️ Technologies Used

### Core Technologies

<table>
  <tr>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/kubernetes/kubernetes-plain.svg" width="60"><br><b>Kubernetes</b><br>Container orchestration</td>
    <td align="center"><img src="https://hexmos.com/freedevtools/svg_icons/k3s/k3s-original-wordmark.svg" width="60"><br><b>K3s</b><br>Lightweight Kubernetes</td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-plain.svg" width="60"><br><b>Docker</b><br>Containerization</td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vagrant/vagrant-original.svg" width="60"><br><b>Vagrant</b><br>VM automation</td>
  </tr>
  <tr>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/argocd/argocd-original.svg" width="60"><br><b>ArgoCD</b><br>GitOps CD</td>
    <td align="center"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/gitlab/gitlab-original.svg" width="60"><br><b>GitLab</b><br>Git + CI/CD</td>
    <td align="center"><img src="https://helm.sh/img/helm.svg" width="60"><br><b>Helm</b><br>Package manager</td>
    <td align="center"><img src="https://raw.githubusercontent.com/traefik/traefik/master/docs/content/assets/img/traefik.logo.png" width="60"><br><b>Traefik</b><br>Ingress controller</td>
  </tr>
</table>

### Additional Tools

- **Alpine Linux**: Lightweight base OS
- **K3d**: K3s in Docker
- **Flannel**: CNI networking
- **K9s**: Terminal UI for Kubernetes
- **kubectl**: Kubernetes CLI

---

## 📚 Resources

### Official Documentation

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [K3s Documentation](https://docs.k3s.io/)
- [K3d Documentation](https://k3d.io/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitLab Documentation](https://docs.gitlab.com/)
- [Helm Documentation](https://helm.sh/docs/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)

### Learning Resources

- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [GitOps Principles](https://opengitops.dev/)
- [The Twelve-Factor App](https://12factor.net/)
- [CNCF Landscape](https://landscape.cncf.io/)

### Community

- [Kubernetes Slack](https://kubernetes.slack.com/)
- [CNCF](https://www.cncf.io/)
- [DevOps Subreddit](https://www.reddit.com/r/devops/)

---

## 🤝 Contributing

This is an educational project. Feel free to:

- 🐛 Report issues
- 💡 Suggest improvements
- 📖 Improve documentation
- 🔧 Submit pull requests

---

## 📄 License

This project is part of the 42 School curriculum.

---

<div align="center">

**Happy Kubernetes Learning! 🚀**

If you found this project helpful, please consider giving it a ⭐

</div>
