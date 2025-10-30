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

Set `K3S_SSH_USER` in your shell (e.g., `export K3S_SSH_USER=ubuntu`) before running playbooks so Ansible connects with the correct remote account.
