# Implementation Plan: Set Up Pi k3s Cluster

**Branch**: `001-deploy-pi-k3s` | **Date**: 2025-10-29 | **Spec**: [specs/001-deploy-pi-k3s/spec.md](spec.md)
**Input**: Feature specification from `/specs/001-deploy-pi-k3s/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Stand up a four-node Raspberry Pi k3s cluster with three HA control-plane members (server+agent) and one worker using Ansible automation. Operators will manage workloads manually with kubectl and helm while producing diff evidence, documenting runbooks, and validating observability, secrets hygiene, and rebuild drills in line with the constitution.

## Technical Context

**Language/Version**: Bash automation & Ansible 2.16+, Kubernetes manifests for k3s v1.29 (stable channel)  
**Primary Dependencies**: k3s (embedded etcd), Helm 3.x, Ansible collections (`community.general`, `kubernetes.core`), Mozilla SOPS + age for secrets, kube-prometheus-stack for observability  
**Storage**: k3s embedded etcd; k3s local-path provisioner for PVCs, optional Longhorn evaluation documented but not enabled by default  
**Testing**: `ansible-playbook --check`, `ansible-lint`, `kubectl diff`, manual HA failover drills, shell smoke tests for node health  
**Target Platform**: Raspberry Pi 4 Model B (8GB RAM) running 64-bit Raspberry Pi OS Lite with cgroups v2 enabled  
**Project Type**: Infrastructure-as-code repository (Ansible playbooks + Kubernetes manifests)  
**Tooling**: `uv`-managed Python virtual environment for Ansible tooling and linters  
**Performance Goals**: Node rebuild ≤60 minutes, alert delivery ≤5 minutes for critical events, maintain 95% drift-free deployment rate, cluster services stable under home-lab loads  
**Constraints**: ARM64-only workloads, limited IO throughput on SD/SSD media, residential power/network variability, manual manifest application workflow  
**Scale/Scope**: Four-node HA test bed (3 control-plane server+agent, 1 worker); roadmap accommodates growth to ≤10 nodes with documented deviations

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **GitOps Source of Truth**: Repository will store Ansible roles, Helm charts, and manifests; every change captures `kubectl diff` output and operator notes before merge.
- **Reproducible Node Images**: Ansible roles provision OS prerequisites, install k3s, and support idempotent reruns (`ansible-playbook --check` logs committed alongside runbooks).
- **Least-Privilege & Secrets**: SOPS + age encrypts kubeconfigs and tokens; operator SSH access limited to short-lived certs with rotation schedule defined in runbooks.
- **Observability & Self-Healing**: Deploy kube-prometheus-stack, Loki, and alertmanager manifests with documented alert routes and liveness probes defined for workloads.
- **Documentation & Runbooks**: Update/author runbooks for bootstrap, HA failover, rebuild, manual apply workflow, secrets rotation, and observability checks; summarize validations in governance log.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
automation/
├── ansible/            # Node bootstrap + configuration management
├── scripts/            # Helper shell scripts invoked by CI or operators
└── images/             # Optional image build definitions (e.g., Packer)

cluster/
├── base/               # Shared manifests (namespaces, ingress, monitoring)
├── apps/               # Workload overlays per application/service
└── policies/           # RBAC, PodSecurity, network policies

docs/
├── runbooks/           # Operational guides mapped to services/automation
└── governance/         # Constitution, review logs, decision records

tests/
├── k8s-diff/           # Snapshot/diff assertions for manifests
└── automation/         # Idempotence or smoke tests for provisioning
```

**Structure Decision**: Organize automation under `automation/ansible/` with local roles for `base_os` hardening and `static_network` netplan management, and rely on the upstream `k3s-ansible` collection for server/agent orchestration. Kubernetes manifests reside in `cluster/base/` (namespace, monitoring, storage) and `cluster/apps/` (workload overlays). Operational documentation lives in `docs/runbooks/` and governance notes in `docs/governance/`. Tests persist in `tests/automation/` (Ansible smoke/idempotence) and `tests/k8s-diff/` (manifest drift).

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

## Phase 0: Research & Unknown Resolution

1. Inventory prerequisites for Raspberry Pi OS preparation (64-bit image, cgroups v2, kernel tweaks) and codify in Ansible role.
2. Validate k3s HA topology (3 server+agent, 1 worker) and document etcd quorum, service load distribution, and failover expectations.
3. Confirm SOPS + age workflow (key custody, encryption targets, CI usage) and record rotation cadence.
4. Select network stack defaults (flannel CNI, kube-vip vs. built-in service LB) and document home-lab IP planning.
5. Choose observability bundle (kube-prometheus-stack + Loki + alertmanager routing) with arm64 compatibility affirmed.
6. Capture manual deployment evidence expectations (diff collection, logging) and governance trail format.

**Research Outputs**  
- `/specs/001-deploy-pi-k3s/research.md` containing Decision/Rationale/Alternatives for each item above.  
- Preliminary checklist of runbooks to author/update.

## Phase 1: Design, Data Model & Contracts

1. Translate Cluster Node Profile, Configuration Change Record, and Provisioning Run entities into `data-model.md` with fields, validation, and relationships.
2. Define operational contract (OpenAPI) for recording manual actions: bootstrap, rebuild, diff submission, alert acknowledgement.
3. Define `uv` project configuration (`pyproject.toml` or `uv.lock`) documenting Python dependencies and virtual environment workflow.
4. Draft `quickstart.md` covering workstation setup (kubectl, helm, uv-based Ansible env), secrets bootstrapping, and first cluster bootstrap walkthrough.
5. Generate baseline Kubernetes manifest layout (directories, naming conventions) and map to automation playbooks (base OS role + k3s-ansible collection).
6. Update agent context via `.specify/scripts/bash/update-agent-context.sh codex` with new technologies (Ansible roles, SOPS-age workflow, kube-prometheus-stack).
7. Re-run Constitution Check ensuring design artifacts demonstrate compliance; document outcomes in plan.

## Phase 2: Implementation Preparation (Stop Point)

1. Outline forthcoming tasks for `/speckit.tasks` (provisioning automation, secrets management, observability deployment, runbook validation).
2. Identify testing strategy (automation smoke tests, failover drills) and note required test harness updates.
3. Confirm readiness checklist: research complete, design files present, constitution gates satisfied, agent context updated.

## Constitution Gate Re-Check (Post-Design)
- **GitOps Source of Truth**: `cluster/` manifests and automation roles tracked in repo; manual diffs recorded per `contracts` API and governance logs.
- **Reproducible Node Images**: Ansible roles + rebuild run instructions documented in `data-model.md` and `quickstart.md`; idempotence via `ansible-playbook --check`.
- **Least-Privilege & Secrets**: SOPS + age workflow defined in research; plan mandates rotation schedule and encrypted artifacts.
- **Observability & Self-Healing**: kube-prometheus-stack + Loki deployment outlined; alert tests captured in contracts and quickstart.
- **Documentation & Runbooks**: Quickstart, runbook scope, and governance updates planned; `/docs/runbooks/` targets enumerated for Phase 1 outputs.
