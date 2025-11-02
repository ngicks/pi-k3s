# Secrets Setup
- `.sops.yaml` files in the repo target an age recipient (`age167hh84wz5rpp0wk6h3h0pgxl7lrqd686hlk8dd4e08lejt48mqkq4fggny`).
- To decrypt SOPS files you must provide the matching age private key via `SOPS_AGE_KEY_FILE`.
- The repository does not ship any encrypted vault data; `automation/ansible/group_vars/all/vault.sops.yaml` is expected to be created locally with SOPS.