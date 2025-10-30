---

description: "Task list for feature implementation"
---

# Tasks: Set Up Pi k3s Cluster

**Input**: Design documents from `/specs/001-deploy-pi-k3s/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Use CI dry-runs (`kubectl diff`, `ansible-playbook --check`) and lightweight shell tests. Include them only if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- `automation/ansible/`: Provisioning and configuration playbooks.
- `automation/scripts/`: Shell helpers invoked manually or via CI.
- `cluster/base/`: Shared manifests (namespaces, ingress, monitoring).
- `cluster/apps/<service>/`: Workload-specific overlays.
- `docs/runbooks/`: Operational documentation to update with every change.
- `docs/governance/`: Compliance evidence and review logs.
- `tests/automation/` & `tests/k8s-diff/`: Idempotence checks and manifest diff assertions.

<!-- 
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.
  
  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/
  
  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment
  
  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: GitOps & Documentation Foundations

**Purpose**: Prepare repository artifacts, inventory, and configuration required before automation work begins.

- [X] T001 Create Ansible inventory with control-plane/workers groups in `automation/ansible/inventory/hosts.yml`.
- [X] T002 Add Ansible configuration defaults (pipelining, callbacks) in `automation/ansible/ansible.cfg`.
- [X] T003 [P] Initialize `uv` project configuration in `pyproject.toml` declaring Ansible tooling dependencies (`ansible`, `ansible-lint`, `kubernetes`).
- [X] T004 [P] Document `uv` environment setup and usage steps in `README.md`, including commands to create/activate the virtual environment.

---

## Phase 2: Provisioning & Node Health Prerequisites

**Purpose**: Ensure automation scaffolding, secrets handling, and manual diff capture exist before story work.

- [ ] T005 Create role scaffolding (`tasks/`, `handlers/`, `templates/`) for `base_os`, `k3s_server`, `k3s_agent`, and `post_bootstrap` under `automation/ansible/roles/`.
- [ ] T006 [P] Stub playbook entry points in `automation/ansible/site.yml` with plays targeting control-plane and worker groups.
- [ ] T007 [P] Configure repository-wide SOPS policy in `.sops.yaml` covering `cluster/` and `docs/governance/`.
- [ ] T008 [P] Add diff collection helper script `automation/scripts/collect-diff.sh` that wraps `kubectl diff`/`helm diff` and stores artifacts under `docs/governance/reviews/`.
- [ ] T009 [P] Capture secrets rotation checklist skeleton in `docs/runbooks/secrets-rotation.md`.
- [ ] T010 Record hardware/environment prerequisites in `docs/runbooks/hardware.md`.

**Checkpoint**: Provisioning scaffolding ready; story-specific automation can proceed.

---

## Phase 3: User Story 1 - Bootstrap Minimal Managed Cluster (Priority: P1) 🎯 MVP

**Goal**: Bootstrap minimal managed cluster with Ansible-driven provisioning and manual manifest application.

**Independent Test**: Run `ansible-playbook --check` then full apply, confirm all four nodes register with expected roles and baseline manifests apply cleanly.

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Capture `kubectl diff`/`helm template` output before applying**

- [ ] T011 [P] [US1] Create bootstrap automation smoke test script `tests/automation/test_bootstrap.sh` invoking `ansible-playbook --check`.
- [ ] T012 [P] [US1] Add baseline manifest diff test `tests/k8s-diff/test_baseline.sh` to assert clean diffs before apply.

### Implementation for User Story 1

- [ ] T013 [P] [US1] Implement OS preparation tasks in `automation/ansible/roles/base_os/tasks/main.yml`.
- [ ] T014 [P] [US1] Implement control-plane install tasks in `automation/ansible/roles/k3s_server/tasks/main.yml`.
- [ ] T015 [P] [US1] Implement worker install tasks in `automation/ansible/roles/k3s_agent/tasks/main.yml`.
- [ ] T016 [US1] Implement kubeconfig retrieval and post-bootstrap steps in `automation/ansible/roles/post_bootstrap/tasks/main.yml`.
- [ ] T017 [US1] Wire roles with variables/handlers inside `automation/ansible/site.yml` for full-cluster apply.
- [ ] T018 [US1] Create baseline cluster manifests (namespaces, storage, RBAC) in `cluster/base/system/`.
- [ ] T019 [US1] Author operator bootstrap SOP in `docs/runbooks/bootstrap.md` referencing diff helper script.
- [ ] T020 [US1] Document manual apply workflow and evidence logging in `docs/governance/reviews/bootstrap-template.md`.

**Checkpoint**: Cluster bootstraps via Ansible, baseline manifests apply, and documentation/evidence workflow verified.

---

## Phase 4: User Story 2 - Rebuild Failed Node Rapidly (Priority: P2)

**Goal**: Rebuild failed node within 60 minutes using idempotent automation and documented drills.

**Independent Test**: Wipe worker node storage, rerun Ansible with `--limit pi-cluster-4.local`, confirm node rejoins cluster and workloads reschedule inside 60 minutes while logging metrics.

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T021 [P] [US2] Add rebuild convergence test `tests/automation/test_rebuild.sh` simulating wipe and verifying duration.
- [ ] T022 [P] [US2] Add governance checklist test `tests/k8s-diff/test_rebuild_evidence.sh` ensuring evidence artifacts exist.

### Implementation for User Story 2

- [ ] T023 [P] [US2] Add rebuild play targeting `pi-cluster-4.local` with tags in `automation/ansible/site.yml`.
- [ ] T024 [P] [US2] Implement rebuild-specific tasks and handlers in `automation/ansible/roles/k3s_agent/tasks/rebuild.yml`.
- [ ] T025 [US2] Create rebuild automation wrapper `automation/scripts/rebuild-node.sh` measuring elapsed time.
- [ ] T026 [US2] Capture detailed rebuild runbook in `docs/runbooks/rebuild-node.md` with validation checklist.
- [ ] T027 [US2] Add governance template `docs/governance/reviews/rebuild-drill-template.md` for quarterly drills.

**Checkpoint**: Node rebuild workflow validated with documentation and evidence logged.

---

## Phase 5: User Story 3 - Monitor and Document Cluster Operations (Priority: P3)

**Goal**: Establish observability, alert routing, and documentation to monitor HA cluster operations.

**Independent Test**: Deploy monitoring stack, trigger synthetic alerts, and confirm notifications plus runbook guidance resolve incident without manual cluster edits.

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T028 [P] [US3] Add alert route validation script `tests/k8s-diff/test_alert_routes.sh`.
- [ ] T029 [P] [US3] Create log pipeline smoke test `tests/automation/test_loki_pipeline.sh`.

### Implementation for User Story 3

- [ ] T030 [P] [US3] Add kube-prometheus-stack values in `charts/kube-prometheus-stack/values.yaml` tailored for arm64 nodes.
- [ ] T031 [P] [US3] Define Loki deployment manifest in `cluster/base/observability/loki.yaml`.
- [ ] T032 [US3] Configure alertmanager routes in `cluster/base/observability/alertmanager-config.yaml`.
- [ ] T033 [US3] Document observability operations in `docs/runbooks/observability.md` including alert drill steps.
- [ ] T034 [US3] Finalize secrets rotation procedures in `docs/runbooks/secrets-rotation.md` with verification steps.
- [ ] T035 [US3] Add governance log template `docs/governance/reviews/alert-test-template.md` for synthetic outages.

**Checkpoint**: Observability stack operational with alert routes documented and validated.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Harden operations, finalize documentation, and confirm governance evidence.

- [ ] T036 [P] Cross-verify `quickstart.md` against all runbooks and update inconsistencies in `docs/runbooks/`.
- [ ] T037 [P] Populate example diff artifact bundle in `docs/governance/reviews/sample-bootstrap-diff/`.
- [ ] T038 Run end-to-end drill (bootstrap → rebuild → alert test) and capture summary in `docs/governance/reviews/end-to-end-validation.md`.
- [ ] T039 Prepare handoff notes in `README.md` summarizing follow-up TODOs derived from this feature.

---

## Dependencies & Execution Order

### Phase Dependencies

- **GitOps & Documentation (Phase 1)**: No dependencies - establish repo scaffolding first.
- **Provisioning & Node Health (Phase 2)**: Depends on Phase 1 completion - BLOCKS all user stories.
- **User Stories (Phase 3+)**: Depend on Phase 2 completion; execute in priority order (US1 → US2 → US3).
- **Polish (Final Phase)**: Depends on all user stories being complete and validated.

### User Story Dependencies

- **User Story 1 (P1)**: Starts after Phase 2; no dependency on other stories.
- **User Story 2 (P2)**: Requires US1 automation baseline to exist but remains independently testable via rebuild drills.
- **User Story 3 (P3)**: Depends on US1 infrastructure for metrics endpoints; rebuild workflows (US2) not strictly required but enhance alert testing.

### Within Each User Story

- Diff/dry-run evidence MUST exist before applying manifests.
- Secrets and RBAC updates MUST be merged only after reviewers confirm scope.
- Runbook documentation MUST be drafted alongside manifest changes.
- Monitoring/alert updates MUST be validated before declaring the story complete.

### Parallel Opportunities

- All Phase 1 tasks marked [P] can run in parallel (inventory config, requirements file).
- Phase 2 tasks marked [P] can run in parallel (SOPS setup, diff helper, documentation scaffolds).
- Within US1, parallelize role implementations (`base_os`, `k3s_server`, `k3s_agent`).
- Within US2, rebuild automation and documentation can progress concurrently once tags exist.
- Within US3, Helm values, Loki manifests, and alert routes can be authored simultaneously after secrets workflow is finalized.

---

## Parallel Example: User Story 1

```bash
# Launch dry-run checks for User Story 1 together (if requested):
Task: "Run kubectl diff for cluster/base/system/"
Task: "Run ansible-playbook --check automation/ansible/site.yml"

# Launch all observability updates for User Story 1 together:
Task: "Validate manifest diff via tests/k8s-diff/test_baseline.sh"
Task: "Update governance evidence template in docs/governance/reviews/bootstrap-template.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: GitOps & Documentation Foundations
2. Complete Phase 2: Provisioning & Node Health (blocks workload phases)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Run bootstrap smoke tests, collect diff evidence, and confirm runbooks
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Phases 1 + 2 → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Phases 1 + 2 together
2. Once Phase 2 is done:
   - Developer A: User Story 1 (Ansible roles + baseline manifests)
   - Developer B: User Story 2 (rebuild automation + drills)
   - Developer C: User Story 3 (observability + alerting)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
