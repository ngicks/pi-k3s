<!--
Sync Impact Report
- Version change: 1.0.1 → 1.1.0
- Modified principles: none
- Added sections: none
- Removed sections: none
- Modified sections: Development & Operations Workflow (added Serena knowledge stewardship clause), Governance (mandated Serena tooling compliance)
- Templates requiring updates: .specify/templates/plan-template.md ✅ updated, .specify/templates/spec-template.md ✅ updated, .specify/templates/tasks-template.md ✅ updated
- Follow-up TODOs: none
-->
# pi-k3s Constitution

## Core Principles

### I. GitOps Evidence & Traceability
pi-k3s treats the repository as the single source of truth for infrastructure state.
- Commit Ansible playbooks, Helm charts, Kubernetes manifests, and SOPS rules before any execution.
- Capture and store `ansible-playbook --check`, `kubectl diff`, and `helm diff` output under `docs/governance/reviews/<date>-<change>/` prior to merging or applying changes.
- Reject manual cluster alterations that lack repository evidence or a governance log entry.
**Rationale**: Enforcing GitOps discipline keeps the cluster observable, auditable, and recoverable.

### II. Reproducible Automation & Rebuild Drills
Automation must guarantee the cluster can be rebuilt predictably within home-lab constraints.
- Maintain idempotent Ansible roles and document required variables; failed checks must be fixed before production runs.
- Keep bootstrap, HA failover, and rebuild runbooks current, with a 60-minute rebuild SLO for any node.
- Schedule and log quarterly rebuild drills covering both control-plane and worker nodes.
**Rationale**: Repeatable automation prevents drift and assures recovery from hardware failures.

### III. Least-Privilege Secrets & Access Governance
Secrets management prioritizes encryption, limited blast radius, and timely rotation.
- Manage credentials exclusively via Mozilla SOPS + age; plaintext secrets MUST NOT enter the repository or command history.
- Restrict SSH, kubeconfig, and token issuance to time-bound credentials referenced by encrypted inventory files.
- Rotate SOPS recipients and review access logs after each secrets change or onboarding event.
**Rationale**: Least privilege and encrypted custody reduce exposure from compromised home-lab devices.

### IV. Observability & Alerting Validation
Operational readiness depends on continuous telemetry and alert coverage.
- Deploy kube-prometheus-stack, Loki, and alertmanager as mandatory base manifests with version drift monitored.
- Instrument workloads with structured logging, readiness probes, and resource alerts before declaring them production-ready.
- Execute synthetic alert drills after each material change and archive outcomes in governance records.
**Rationale**: Continuous observability ensures failures surface quickly and operators can respond with evidence.

### V. Runbooks & Manual Change Control
Manual interventions are allowed only when backed by current documentation and audit trails.
- Publish runbooks covering bootstrap, manual apply workflow, secrets rotation, alert response, and rebuild drills in `docs/runbooks/`.
- Update runbooks and quickstart guides within 24 hours of discovering deviations or completing drills.
- Require governance reviews to cite the applicable runbook section and evidence artifacts before closing.
**Rationale**: Consistent documentation keeps manual processes safe despite human-in-the-loop operations.

## Operational Constraints & Stack Requirements

pi-k3s operates a four-node Raspberry Pi 4 Model B (8GB RAM) cluster managed entirely from this repository. The automation stack MUST use Ansible 2.16+ with `community.general` and `kubernetes.core` collections executed from the uv-managed virtual environment. Kubernetes workloads run on k3s v1.29 (stable channel) with embedded etcd; manifests must target ARM64 compatibility and honor the documented directory structure (`automation/`, `cluster/`, `docs/`, `tests/`). Helm 3.x handles packaged components, and observability relies on kube-prometheus-stack plus Loki. All secrets, inventories, and kubeconfigs stored in the repository must remain SOPS-encrypted with age recipients maintained in `.sops.yaml`. Hardware limitations (ARM64, constrained IO, residential network) require operators to document performance deviations and mitigation in governance logs.

## Development & Operations Workflow

Work proceeds in deliberate increments that preserve auditability.
- Initiate changes through feature specs and plans that explicitly reference each principle’s gate.
- Before execution, collect dry-run diffs (`ansible-playbook --check`, `kubectl diff`, `helm diff`) and link them to the change record.
- Apply changes under operator observation, then update runbooks, quickstart steps, and governance logs with observed outcomes.
- Schedule observability drills, secrets rotation, and rebuild exercises as tasks within feature plans to keep compliance continuous.
- Archive diff artifacts and governance notes under `docs/governance/reviews/<date>-<change>/` and link them in the change record.
- Capture knowledge updates through Serena-managed templates (`.specify/templates`) and write back to `.specify/memory/` so automation and operators share a single source of procedural truth.
- Submit compliance statements during reviews confirming that principles, operational constraints, and workflow steps were satisfied.

## Governance

The constitution supersedes conflicting project guidance. Amendments require maintainer consensus recorded in `docs/governance/reviews/constitution-log.md`, including summary, rationale, affected principles, and evidence of a compliance review. Versioning follows semantic rules: MAJOR for removing or redefining principles, MINOR for adding principles or expanding operational requirements, PATCH for clarifications that do not change obligations. Every pull request must include a Constitution Check noting how work satisfies each principle; reviewers MUST block merges lacking evidence. A quarterly governance review validates observability drills, secrets rotation, rebuild compliance, and documentation freshness; findings feed back into runbooks and future specs. Serena MCP must record constitution-aligned updates: operators log decisions and template changes via `.specify/memory/` so reviewers can audit knowledge stewardship alongside infrastructure evidence.

**Version**: 1.1.0 | **Ratified**: 2025-11-03 | **Last Amended**: 2025-11-05
