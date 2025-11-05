## k3s automation migration (2025-11-04)
- Local `k3s_server`, `k3s_agent`, and `post_bootstrap` roles were removed in favor of the upstream `k3s-ansible` collection.
- `automation/ansible/site.yml` now runs the `base_os` role and imports `k3s.orchestration.site`; inventory is modelled after the collection sample (groups `server`/`agent`).
- Cluster leader API endpoint is configured in `automation/ansible/inventory/hosts.yml` via `api_endpoint`, with `token` sourced from `vault_k3s_cluster_token`.
- Documentation (README, quickstart, bootstrap runbook, plan/tasks) updated to describe new workflow and collection install step.