# p1 - Vagrant Multi-VM Environment

This directory contains the configuration for a Vagrant-based environment with two Alpine Linux virtual machines.

## Structure

- **Vagrantfile**: Defines two VMs (`RobrodriS` and `RobrodriSW`) using the `generic/alpine318` box. Sets up private networking and a shared folder.
- **scripts/**
  - `server.sh`: Provisioning script for the main server VM (`RobrodriS`).
  - `worker.sh`: Provisioning script for the worker VM (`RobrodriSW`).
- **shared/**: Shared folder between the host and both VMs, mounted at `/vagrant_shared` inside the VMs.

## Virtual Machines

- **RobrodriS**: Main server, IP `192.168.56.110`.
- **RobrodriSW**: Worker server, IP `192.168.56.111`.

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

## Notes

- The `shared` folder is mounted as `/vagrant_shared` in both VMs.
- You can customize the provisioning scripts in the `scripts/` directory as needed.
