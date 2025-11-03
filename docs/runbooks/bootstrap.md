# Runbook: Cluster Bootstrap

## Purpose
Establish a reproducible procedure for provisioning the pi-k3s control-plane and worker nodes, applying baseline manifests, and capturing governance evidence.

## Prerequisites
- Operators have access to this repository and have pulled the latest `001-deploy-pi-k3s` branch.
- Workstation environment prepared per `specs/001-deploy-pi-k3s/quickstart.md` (uv virtualenv active, `ansible-playbook`, `kubectl`, `helm`, `age`, `sops` installed).
- `automation/ansible/group_vars/all/vault.sops.yaml` contains `vault_k3s_cluster_token` and any sensitive credentials.
- Environment variables:
  - `export K3S_SSH_USER=<remote_username>`
  - `export K3S_API_ENDPOINT=<control-plane load balancer or primary server address>`
  - `export K3S_CLUSTER_TOKEN=$(sops -d --extract '["vault_k3s_cluster_token"]' automation/ansible/group_vars/all/vault.sops.yaml)`

## Step 1: Dry-Run Automation
1. Activate the virtual environment (`source .venv/bin/activate`).
2. Run the bootstrap smoke test to execute `ansible-playbook --check`:
   ```bash
   tests/automation/test_bootstrap.sh
   ```
3. Review the output; resolve any reported changes or failures before proceeding.

## Step 2: Execute Ansible Bootstrap
1. Run the full playbook to prepare control-plane nodes, workers, and post-bootstrap tasks:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/site.yml
   ```
2. Monitor output for host reboots (triggered when kernel parameters change) and rerun the playbook after reboot if required.
3. Confirm the generated kubeconfig at `~/.kube/pi-k3s.yaml`. Update your shell context:
   ```bash
   export KUBECONFIG=~/.kube/pi-k3s.yaml
   kubectl get nodes -o wide
   ```

## Step 3: Capture Baseline Diffs
1. Validate manifests before applying:
   ```bash
   tests/k8s-diff/test_baseline.sh
   ```
2. Run the diff helper to archive evidence:
   ```bash
   automation/scripts/collect-diff.sh cluster/base/system docs/governance/reviews/$(date +%Y-%m-%d)-bootstrap
   ```
3. Ensure diff artifacts and command logs are committed with the change request.

## Step 4: Apply Baseline Manifests
1. Apply namespaces, storage, and RBAC manifests:
   ```bash
   kubectl apply -f cluster/base/system/
   ```
2. Record command output in `docs/governance/reviews/<date>-bootstrap.md` using the template referenced below.

## Step 5: Post-Bootstrap Validation
1. Verify all nodes are `Ready` and expected roles are present.
2. Deploy kube-prometheus-stack per observability tasks once this runbook completes.
3. Log bootstrap completion via the operations API (see `contracts/cluster-operations.openapi.yaml`) or by creating an entry in `docs/governance/reviews/<date>-bootstrap.md`.

## Evidence & Documentation Requirements
- Store diff outputs under `docs/governance/reviews/<date>-bootstrap/`.
- Update this runbook if deviations occur; cite line references in change reviews.
- Ensure the governance review template described in `docs/governance/reviews/bootstrap-template.md` is populated and committed.

## Rollback
- If bootstrap fails before kubeconfig retrieval, rerun the playbook after addressing the error.
- If manifests apply unexpectedly, use `kubectl delete -f cluster/base/system/` to revert and capture the rollback diff in governance artifacts.
