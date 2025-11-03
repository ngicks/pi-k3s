# Bootstrap Review Template

- **Date**: YYYY-MM-DD
- **Operators**: `<name>`
- **Feature Branch / PR**: `<link>`
- **Kubeconfig Artifact**: `~/.kube/pi-k3s.yaml` (commit hash)
- **Diff Artifacts**: `docs/governance/reviews/<date>-bootstrap/`

## 1. GitOps Evidence & Traceability
- [ ] `ansible-playbook --check` output archived
- [ ] `kubectl diff -f cluster/base/system/` output archived
- [ ] `helm diff` (if applicable) output archived
- Notes:

## 2. Reproducible Automation & Rebuild Drills
- [ ] Ansible playbook run successful without manual edits
- [ ] Reboot events captured (if triggered)
- [ ] Follow-up tasks recorded for rebuild drill
- Notes:

## 3. Least-Privilege Secrets & Access Governance
- [ ] `vault_k3s_cluster_token` rotated or confirmed current
- [ ] Access logs reviewed after token usage
- [ ] SOPS recipients validated
- Notes:

## 4. Observability & Alerting Validation
- [ ] Baseline metrics endpoints responding (`kubectl get --raw /readyz`)
- [ ] Alert test scheduled after bootstrap
- [ ] Logging pipeline plan confirmed
- Notes:

## 5. Runbooks & Manual Change Control
- [ ] `docs/runbooks/bootstrap.md` referenced and updated if deviations occurred
- [ ] Next actions documented in runbook or quickstart
- [ ] Governance log entry committed with artifact links
- Notes:

## Summary
- Outcomes:
- Follow-up Actions / Owners:
- Next Review Window:
