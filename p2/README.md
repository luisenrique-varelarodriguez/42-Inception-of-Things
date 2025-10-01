# p2 - Kubernetes Multi-App Environment

This directory contains the configuration for a Vagrant-based Alpine Linux VM running a Kubernetes cluster with multiple sample applications and an Ingress controller.

## Structure

- **Vagrantfile**: Defines a VM (`RobrodriS`) using the `generic/alpine318` box. Sets up private networking and a shared folder.
- **scripts/**
  - `server.sh`: Provisioning script for the server VM. Installs and configures Kubernetes and required dependencies automatically.
- **shared/**
  - **deployments/**: Kubernetes deployment manifests for the sample applications (`app1`, `app2`, `app3`).
  - **services/**: Kubernetes service manifests for each application.
  - **ingress/**: Ingress resource manifest for routing traffic to the applications.

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
   kubectl apply -f /vagrant_shared/ingress/ingress.yml
   ```

## Notes

- The `shared` folder is mounted as `/vagrant_shared` in the VM.
- The Ingress resource uses the `traefik` ingress class and routes traffic based on the host.
- You can customize the deployments, services, and ingress rules in the `shared/` directory.

### Accessing apps from the host
If you do not want to edit your `/etc/hosts` file, you can use curl to specify the Host header for each app:

```sh
curl -H "Host: app1.com" http://192.168.56.110/
curl -H "Host: app2.com" http://192.168.56.110/
curl -H "Host: app3.com" http://192.168.56.110/
```

This will route your request to the correct app through Traefik Ingress.
