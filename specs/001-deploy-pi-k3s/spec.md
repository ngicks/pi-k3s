# Feature Specification: Set Up Pi k3s Cluster

**Feature Branch**: `001-deploy-pi-k3s`  
**Created**: 2025-10-29  
**Status**: Draft  
**Input**: User description: "set up k3s cluster on raspberry pi 4 model B machines."

## Clarifications

### Session 2025-10-29

- Q: Which GitOps controller or automation should manage cluster-to-repository synchronization? → A: Manual deployment using k3s kubectl on nodes plus kubectl/helm from the operator workstation.
- Q: What automation framework provisions k3s on Raspberry Pi nodes? → A: Use Ansible playbooks to configure nodes and install k3s.
- Q: How should the four Raspberry Pi nodes be assigned for HA testing? → A: Nodes 1–3 run k3s server+agent mode while node 4 runs as a worker-only node.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Bootstrap Minimal Managed Cluster (Priority: P1)

Platform maintainers need to provision a baseline k3s control plane across Raspberry Pi 4 Model B nodes using the automation repository, with deployments executed manually via kubectl and helm.

**Why this priority**: No workloads or governance practices can function until the cluster is live and operators can apply manifests reliably.

**Independent Test**: Run the provisioning playbook against clean hardware, apply baseline manifests with kubectl/helm, and confirm cluster health via automated checks.

**Acceptance Scenarios**:

1. **Given** four Raspberry Pi 4 nodes with approved hardware specs, **When** maintainers run the bootstrap automation, **Then** hosts `pi-cluster-1.local` through `pi-cluster-3.local` come online as control-plane members (server+agent) and `pi-cluster-4.local` registers as the dedicated worker ready for manual manifest application.
2. **Given** the repository of baseline manifests, **When** a change is staged, **Then** operators produce diff evidence (e.g., `kubectl diff`) before applying the update and record the outcome.

---

### User Story 2 - Rebuild Failed Node Rapidly (Priority: P2)

Operations staff must be able to rebuild any failed Pi node from blank media and have it rejoin the cluster with the correct role and workloads within 60 minutes.

**Why this priority**: Commodity hardware is prone to failure; fast reprovisioning preserves service reliability.

**Independent Test**: Simulate a failed node by wiping its storage, execute the rebuild workflow, and verify time-to-restore and workload rescheduling metrics.

**Acceptance Scenarios**:

1. **Given** a node removed from the cluster inventory, **When** staff rerun the provisioning automation, **Then** the node rejoins the cluster with its previous labels and taints and becomes schedulable within 60 minutes.
2. **Given** the rebuild documentation, **When** a new operator follows the runbook, **Then** they complete the procedure without supervision and record outcomes in the governance log.

---

### User Story 3 - Monitor and Document Cluster Operations (Priority: P3)

Maintainers require real-time observability of cluster health and clear runbooks that cover alerts, upgrades, and secret rotation for the k3s environment.

**Why this priority**: Visibility and documentation enforce the constitution’s observability and runbook principles and enable shared on-call coverage.

**Independent Test**: Trigger synthetic failures (e.g., stop kubelet, rotate secrets) and confirm alerts fire through the documented channel while runbooks guide resolution.

**Acceptance Scenarios**:

1. **Given** monitoring dashboards sourced from the GitOps repo, **When** a node becomes unreachable for more than five minutes, **Then** an alert notifies the maintainer channel and the incident is captured per the runbook.
2. **Given** the documented secrets rotation process, **When** service credentials are rotated, **Then** all affected workloads reconcile without manual edits to live clusters.

---

### Edge Cases

- Node bootstrap fails mid-run (power loss, flaky storage) — automation MUST resume cleanly.
- Secrets rotation occurs during deployment — document blast radius and recovery.
- WAN outage during provisioning — capture fallback steps for applying critical fixes locally.
- Hardware variations (e.g., different SD cards or SSDs) — specify compatibility checks before enrollment.
- Manual apply interrupted mid-operation — document rollback or reapply procedure to restore cluster state.
- Control-plane quorum loss (two or more servers offline) — document recovery steps to restore HA before scheduling workload changes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Provide Ansible-based infrastructure-as-code that installs k3s on Raspberry Pi 4 hardware and equips operators with kubectl/helm workflows (including `kubectl diff`) to apply repository manifests safely.
- **FR-002**: Deliver idempotent Ansible playbooks that rebuild a node from bare media to cluster-ready state within 60 minutes, including hostname, labels, and taints.
- **FR-003**: Establish cluster manifests that configure baseline services (networking, storage class, monitoring stack) using only arm64-compatible workloads.
- **FR-004**: Implement access controls ensuring operators use short-lived credentials; store all long-lived secrets encrypted-at-rest in the repository using the approved encryption workflow with offline-managed keys.
- **FR-005**: Produce runbooks covering bootstrap, node recovery, upgrades, and incident response, with validation evidence logged in governance records.
- **FR-006**: Instrument observability so critical alerts (node offline, control-plane degradation, configuration drift) notify maintainers via the documented channel within five minutes.
- **FR-007**: Document hardware bill of materials, network topology, and required environmental setup (power, cooling) to support the Raspberry Pi fleet.
- **FR-008**: Provide compliance checklist updates demonstrating adherence to constitution principles for configuration traceability, reproducibility, least-privilege, observability, and documentation given the manual deployment strategy.

### Key Entities *(include if feature involves data)*

- **Cluster Node Profile**: Describes Pi hostname, hardware specs, role designation (control-plane/worker), labels, taints, and rebuild playbook reference.
- **Configuration Change Record**: Captures feature branch, diff artifacts, operator approvals, and links to applied manifests for audit trailing.
- **Operational Runbook Entry**: Stores procedure title, prerequisites, step list, validation commands, rollback instructions, and last review date.

### Assumptions & Dependencies

- Raspberry Pi fleet includes at least three 8GB RAM units with reliable SSD storage and PoE or conditioned power.
- Home network provides stable wired Ethernet with static IP assignments or DHCP reservations for all nodes.
- Maintainers will provision an internal secrets management key pair stored offline and referenced by the repository’s encryption workflow.
- Operators have secure shell access from a workstation with kubectl and helm configured against the cluster API endpoint.
- Future workloads will adopt the provided baseline observability stack without requiring incompatible tooling.
- Hosts `pi-cluster-1.local` through `pi-cluster-3.local` are dedicated to the control-plane (server+agent) quorum while `pi-cluster-4.local` remains a worker-only participant for HA evaluation.

## Operational Readiness *(mandatory)*

- **Manual Apply Evidence**: Capture `kubectl diff` output and describe the manual apply sequence for initial deployment; store artifacts alongside pull requests.
- **Idempotence Proof**: Provide rerun logs (`ansible-playbook --check`) showing no unintended changes when automation executes twice sequentially.
- **Access & Secrets**: List operator roles, credential issuance cadence, and encryption key custody; include rotation schedule and approval workflow.
- **Observability Hooks**: Detail metrics, logs, and alert routes configured (e.g., node availability dashboard, alert channel mapping) and how synthetic tests are run.
- **Runbook Updates**: Identify new or updated files in `docs/runbooks/` and summarize validation drills executed after documentation changes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of Raspberry Pi nodes can be rebuilt from blank storage and rejoin the cluster within 60 minutes during quarterly drills.
- **SC-002**: Manual deployment runs surface configuration diffs with no unlogged hotfixes in 95% of changes across the first three months of operation.
- **SC-003**: Critical alerts reach the maintainer communication channel within five minutes of detection with a 98% success rate over 30 days.
- **SC-004**: At least two operators outside the authoring team successfully execute the bootstrap and recovery runbooks without escalation, confirming knowledge transfer.
