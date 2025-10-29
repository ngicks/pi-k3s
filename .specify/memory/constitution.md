<!--
Sync Impact Report
- Version change: N/A → 1.0.0
- Modified principles: [Template placeholders] → I. GitOps Source of Truth; II. Reproducible Node Images; III. Least-Privilege Access & Secret Hygiene; IV. Observability & Self-Healing; V. Documentation & Runbooks
- Added sections: Operational Constraints & Stack; Delivery Workflow & Compliance
- Removed sections: None
- Templates requiring updates: ✅ updated — .specify/templates/plan-template.md, .specify/templates/spec-template.md, .specify/templates/tasks-template.md
- Follow-up TODOs: TODO(SECRET_TOOL); TODO(NETWORK_TOPOLOGY); TODO(VERSION_MATRIX_DOC)
-->

# pi-k3s Constitution

## Core Principles

### I. GitOps Source of Truth
- All cluster configuration (k3s manifests, Helm values, provisioning scripts) MUST live in this repository under version control.
- Deploy pipelines MUST execute a dry-run diff (e.g., `kubectl diff`, `helm template`, `ansible-playbook --check`) and surface results in CI before changes are merged.
- Emergency manual interventions MUST be logged as incidents and reconciled back into automation within 24 hours.
*Rationale:* Git-driven automation keeps the Raspberry Pi fleet reproducible, auditable, and recoverable.

### II. Reproducible Node Images
- Raspberry Pi nodes MUST be provisioned through automated playbooks or scripts that can rebuild a node end-to-end without manual steps.
- Provisioning automation MUST be idempotent; CI or local verification MUST prove that rerunning the workflow converges cleanly.
- A failed node MUST be replaceable within 60 minutes using the documented automation and hardware bill of materials.
*Rationale:* Commodity hardware fails; rebuild discipline keeps the cluster healthy.

### III. Least-Privilege Access & Secret Hygiene
- All credentials MUST be short-lived or rotated automatically; long-lived kubeconfigs are prohibited.
- Secrets committed to the repository MUST remain encrypted end-to-end (e.g., SOPS, sealed-secrets). TODO(SECRET_TOOL): Select and document the encryption mechanism.
- Service accounts and node roles MUST request only required scopes and undergo quarterly permission reviews recorded in governance notes.
*Rationale:* Tight access control limits blast radius on always-on home-lab hardware.

### IV. Observability & Self-Healing
- Cluster metrics, logs, and events MUST feed a declared monitoring stack defined alongside the manifests (e.g., Prometheus, Loki).
- Workloads MUST ship with liveness/readiness or equivalent health checks so automation can restart unhealthy components.
- Critical alerts (node offline >5 minutes, control plane degradation, etc.) MUST page maintainers through a documented channel.
*Rationale:* Remote deployments demand fast detection and recovery.

### V. Documentation & Runbooks
- Every automation change MUST update or add runbooks detailing setup, validation, rollback, and failure-handling steps.
- Merge requests MUST include evidence that documentation (e.g., `docs/runbooks/`, `docs/quickstart.md`) reflects the delivered state.
- Operational runbooks MUST be reviewed quarterly with outcomes logged in the governance record.
*Rationale:* Shared documentation keeps a volunteer rotation effective.

## Operational Constraints & Stack
- Target hardware is Raspberry Pi 4 or newer with 64-bit Linux, cgroups v2, and reliable SD or SSD storage.
- The cluster MUST run k3s from the stable channel pinned to a version matrix tracked in-repo. TODO(VERSION_MATRIX_DOC): Create and maintain the version matrix document.
- Container workloads MUST provide arm64-compatible images or build pipelines for arm64.
- Networking (CNI selection, load balancer, ingress) MUST be documented before deployment. TODO(NETWORK_TOPOLOGY): Capture the cluster networking design.
- Infrastructure-as-code directories (e.g., `infrastructure/`, `cluster/`) MUST declare ownership and expected execution order in README files.

## Delivery Workflow & Compliance
1. **Intake:** Work begins by generating plan/spec/tasks via the `/speckit.plan` and `/speckit.tasks` workflows. Each plan MUST list GitOps, node rebuild, secret hygiene, observability, and documentation gates explicitly.
2. **Implementation:** Changes MUST land with automated diff evidence, idempotence proof for provisioning updates, and references to updated runbooks.
3. **Review:** Pull requests MUST link to their plan/spec/tasks, show passing CI (including dry-run deploys), and include reviewer checklists confirming each principle.
4. **Handover:** Merge is blocked until runbooks and operational notes are updated and linked in the PR description.

## Governance
- This constitution supersedes other workflow documents; conflicting guidance MUST be reconciled through amendment.
- Amendments require an RFC issue outlining the motivation, proposed text, version bump classification (MAJOR/MINOR/PATCH), and updated templates before merge.
- Constitution versioning follows semantic rules: MAJOR for breaking/removing principles, MINOR for new principles/sections, PATCH for clarifications.
- Maintainers MUST run compliance reviews at least quarterly, documenting adherence to each principle and tracking remediation tasks.

**Version**: 1.0.0 | **Ratified**: 2025-10-29 | **Last Amended**: 2025-10-29
