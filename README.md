# pi-k3s

Home-lab automation for provisioning and operating a Raspberry Pi k3s cluster.

## Developer Setup (mise + uv)

1. Ensure [uv](https://docs.astral.sh/uv/) is installed on your system (required for dependency management). The author recommends installing uv with [mise](https://mise.jdx.dev/).
2. Create the local virtual environment (stored in `.venv/`):
   ```bash
   uv venv .venv
   ```
3. Activate the environment before running automation:
   ```bash
   source .venv/bin/activate
   ```
4. Install the required tooling declared in `pyproject.toml`:
   ```bash
   uv pip install -r pyproject.toml
   ```
5. Verify the Ansible CLI is available from the environment:
   ```bash
   ansible-playbook --version
   ```

Whenever dependencies change, rerun `uv pip install -r pyproject.toml` while the environment is active to stay in sync. Deactivate with `deactivate` when finished.

Set `K3S_SSH_USER` before running playbooks so Ansible uses the correct remote account (e.g., `export K3S_SSH_USER=ubuntu`).

Populate sudo credentials by editing the encrypted vault:

```bash
sops automation/ansible/group_vars/all/vault.sops.yml
```

Add the `k3s_sudo_password` value inside the editor; SOPS will re-encrypt the file on save.

## Secrets Management (age + SOPS)

1. **Install tools** (Debian/Ubuntu example):
   ```bash
   sudo apt install -y age sops
   ```
   On other platforms, follow the official docs for [age](https://github.com/FiloSottile/age) and [SOPS](https://github.com/getsops/sops).

2. **Generate an age key pair** and store it under your user config (keep an offline backup of the private key):
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

3. **Expose the key to SOPS** before working with encrypted files:
   ```bash
   export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
   ```

4. **Edit encrypted secrets** using SOPS. For example, to set the sudo password consumed by Ansible:
   ```bash
   sops automation/ansible/group_vars/all/vault.sops.yml
   ```
   SOPS decrypts the file in-memory, lets you edit YAML, and re-encrypts on save. Never commit decrypted copies.

5. **Share public keys only.** Update `.sops.yaml` with any additional recipients so teammates can decrypt using their own age keys.
