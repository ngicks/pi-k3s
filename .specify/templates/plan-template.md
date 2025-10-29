# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

**Language/Version**: Bash & Ansible automation; Kubernetes manifests for k3s  
**Primary Dependencies**: k3s (stable channel), Helm, Ansible ≥2.16, GitOps controller (documented in repo)  
**Storage**: etcd embedded in k3s; optional Longhorn/NFS if feature requires persistent volumes  
**Testing**: Ansible check mode, `kubectl diff`, CI dry-run pipelines, shell unit tests where applicable  
**Target Platform**: Raspberry Pi 64-bit nodes running Linux with cgroups v2  
**Project Type**: Infrastructure-as-code repository  
**Performance Goals**: Sustained cluster uptime >99%, node reprovision <60 minutes  
**Constraints**: ARM64-only workloads, limited memory/IO on Pi hardware, residential power/network  
**Scale/Scope**: Small fleet (≤10 nodes) with home-lab services; document deviations in plan

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **GitOps Source of Truth**: Link CI diff output proving automation-driven deploy.
- **Reproducible Node Images**: Provide idempotence evidence (rerun logs/check mode).
- **Least-Privilege & Secrets**: Declare secret handling and access scope changes.
- **Observability & Self-Healing**: Note monitoring/alert updates and health checks.
- **Documentation & Runbooks**: Identify runbooks/quickstart updates bundled with work.

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

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
