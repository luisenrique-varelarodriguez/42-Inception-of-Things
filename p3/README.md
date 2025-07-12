# p3 - Kubernetes Advanced Environment

This directory contains the configuration for a Vagrant-based Alpine Linux VM running an advanced Kubernetes cluster setup with additional features and applications.

## Structure

- **Vagrantfile**: Defines a VM (`RobrodriS`) using the `generic/alpine318` box. Sets up private networking and a shared folder.
- **scripts/**
  - `server.sh`: Provisioning script for the server VM. Installs and configures Kubernetes and all required dependencies automatically.
- **shared/**
  - **deployments/**: Kubernetes deployment manifests for the advanced applications.
  - **services/**: Kubernetes service manifests for each application.
  - **ingress/**: Ingress resource manifests for routing traffic to the applications.
  - *(Add any other relevant folders or files specific to your setup)*

## Virtual Machine

- **RobrodriS**: Main server, IP `192.168.56.110`.

## Automation

The provisioning process is fully automated. When you run `vagrant up`, the VM is created and all necessary software (Kubernetes, container runtime, etc.) is installed and configured automatically using the scripts in the `scripts/` directory. No manual setup is required.

## Usage

1. Start the VM:
   ```sh
   vagrant up
   ```
2. SSH into the VM:
   ```sh
   vagrant ssh RobrodriS
   ```
3. Apply the Kubernetes manifests as needed, for example:
   ```sh
   kubectl apply -f /vagrant_shared/deployments/
   kubectl apply -f /vagrant_shared/services/
   kubectl apply -f /vagrant_shared/ingress/
   ```

## Notes

- The `shared` folder is mounted as `/vagrant_shared` in the VM.
- You can customize the deployments, services, and ingress rules in the `shared/` directory.
- *(Add any other notes or advanced usage instructions here)*

---

## Accessing the ArgoCD Web UI

> **Note:** Due to networking and certificate issues, you should always port-forward directly to the ArgoCD server pod (not the service).

1. Find the ArgoCD server pod name:
   ```bash
   kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
   ```

2. Port-forward to the pod (example uses port 8888, you can use another if needed):
   ```bash
   kubectl port-forward --address 0.0.0.0 pod/<pod-name> -n argocd 8888:8080
   ```

3. On your host machine, open [https://localhost:8888](https://localhost:8888) in your browser.

---

## Accessing your application from the host

To access your deployed application (for example, to check the version with `curl http://localhost:8888/`), follow these steps:

1. Forward the port in your `Vagrantfile`:
   ```ruby
   server.vm.network "forwarded_port", guest: 8888, host: 8888
   ```
   Then reload your VM:
   ```bash
   vagrant reload
   ```

2. In the VM, port-forward your app service, listening on all interfaces:
   ```bash
   kubectl port-forward --address 0.0.0.0 -n dev svc/app-service 8888:8888
   ```

3. On your Mac (host), you can now run:
   ```bash
   curl http://localhost:8888/
   ```
   You should see the expected response from your application (e.g., `{"status":"ok","message":"v1"}`).

> **Note:** You can use different ports for ArgoCD and your app if you want to access both at the same time.  
> Always use `--address 0.0.0.0` when port-forwarding if you want to access the service from outside the VM.
