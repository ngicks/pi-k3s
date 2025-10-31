# Quickstart: Set Up Pi k3s Cluster

## Prerequisites
- Four Raspberry Pi 4 Model B (8GB RAM) with SSD or high-endurance SD storage, PoE or stable power, and wired Ethernet.
- Workstation (this machine) with:
  - Python 3.11+
  - `uv` CLI for Python environment management
  - `kubectl` 1.29+
  - `helm` 3.14+
  - `age` for key management and `sops` for manifest encryption
- Static IP reservations or documented DHCP leases for each node (`pi-cluster-1.local` … `pi-cluster-4.local`).
- Access to this repository (branch `001-deploy-pi-k3s`).

## 1. Prepare Workstation Environment
1. Install `uv` (Linux example):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
   Restart your shell or source the indicated profile script.
2. Create and activate the project virtual environment:
   ```bash
   uv venv .venv
   source .venv/bin/activate
   ```
3. Install Python dependencies declared in `pyproject.toml`:
   ```bash
   uv pip install -r pyproject.toml
   ```
4. Install SOPS and age (Debian/Ubuntu example):
   ```bash
   sudo apt install sops age
   ```
5. Generate age key pair and store in `~/.config/sops/age/keys.txt` (keep offline backup):
   ```bash
   age-keygen -o ~/.config/sops/age/keys.txt
   ```
6. Export environment variables for SSH identity and SOPS key path:
   ```bash
   export K3S_SSH_USER=ubuntu          # replace with your SSH username
   export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
   ```
7. Populate encrypted sudo credentials:
   ```bash
   sops automation/ansible/group_vars/all/vault.sops.yml
   ```
   Add `k3s_sudo_password` inside the editor; SOPS will encrypt on save.
8. Verify `kubectl` context is unset (will be configured after bootstrap).

## 2. Flash and Configure Raspberry Pi Nodes
1. Flash Raspberry Pi OS Lite 64-bit to each SSD/SD.
2. Enable SSH by creating empty `ssh` file on boot partition.
3. For each node (replace `<n>` with 1–4):
   ```bash
   ssh pi@pi-cluster-<n>.local
   sudo raspi-config nonint do_hostname pi-cluster-<n>
   sudo raspi-config nonint do_ssh 0
   sudo raspi-config nonint do_boot_behaviour B1
   sudo raspi-config nonint do_wait_for_network 1
   sudo reboot
   ```
4. Update inventory in `automation/ansible/inventory/hosts.yml` with node IPs.

## 3. Bootstrap Cluster with Ansible
1. Dry-run playbook to confirm idempotence:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/site.yml --check
   ```
2. Execute full run:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/site.yml
   ```
3. Copy kubeconfig from server node 1 (Ansible task should retrieve automatically to `~/.kube/config`).
4. Test cluster access:
   ```bash
   kubectl get nodes -o wide
   ```
   Expect nodes 1–3 to show role `control-plane` and node 4 as `worker`.

## 4. Apply Baseline Manifests Manually
1. Review diff:
   ```bash
   kubectl diff -f cluster/base/
   helm diff upgrade monitoring charts/kube-prometheus-stack --namespace monitoring --install --values charts/values-monitoring.yaml
   ```
2. Apply changes once diffs reviewed:
   ```bash
   kubectl apply -f cluster/base/
   helm upgrade --install monitoring charts/kube-prometheus-stack --namespace monitoring --create-namespace --values charts/values-monitoring.yaml
   ```
3. Record evidence paths in `docs/governance/reviews/<date>-bootstrap.md`.

## 5. Validate Observability and Alerts
1. Wait for monitoring pods to become Ready:
   ```bash
   kubectl get pods -n monitoring
   ```
2. Trigger synthetic alert test (cordon server node 2):
   ```bash
   kubectl cordon pi-cluster-2
   sleep 300
   kubectl uncordon pi-cluster-2
   ```
3. Confirm alert notification reached maintainer channel and log result in governance review.

## 6. Run Rebuild Drill
1. Power-cycle node 4 and reimage storage.
2. Execute Ansible playbook targeting node 4:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/site.yml --limit pi-cluster-4.local
   ```
3. Ensure node returns to Ready state within 60 minutes and workloads reschedule correctly.
4. Capture duration metrics and update runbook checklist.

## 7. Post-Bootstrap Tasks
- Update `docs/runbooks/` with any deviations discovered.
- Commit generated diff artifacts under `docs/governance/reviews/`.
- Schedule next secrets rotation and alert test dates.
- Prepare for `/speckit.tasks` by reviewing automation outputs and outstanding TODOs.
