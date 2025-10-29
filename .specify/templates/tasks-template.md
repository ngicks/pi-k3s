---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
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

**Purpose**: Prepare repository artifacts required before touching workloads.

- [ ] T001 Update `cluster/base/` manifests and run `kubectl diff` in CI.
- [ ] T002 Refresh `docs/runbooks/<topic>.md` with planned operational changes.
- [ ] T003 [P] Capture compliance notes in `docs/governance/reviews/`.

---

## Phase 2: Provisioning & Node Health Prerequisites

**Purpose**: Ensure automation can rebuild hardware and stays idempotent.

- [ ] T004 Update `automation/ansible/<playbook>.yml` for new capability.
- [ ] T005 [P] Run `ansible-playbook --check` (record logs in PR).
- [ ] T006 [P] Add smoke tests under `tests/automation/` verifying reruns converge.
- [ ] T007 Document hardware assumptions in `docs/runbooks/hardware.md`.

**Checkpoint**: Provisioning automation validated; workload changes can proceed.

---

## Phase 3: Service Workload - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of workload or platform capability delivered]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Capture `kubectl diff`/`helm template` output before applying**

- [ ] T010 [P] [US1] Add manifest diff assertion in `tests/k8s-diff/test_[name].sh`.
- [ ] T011 [P] [US1] Validate alert coverage with monitoring rule test.

### Implementation for User Story 1

- [ ] T012 [P] [US1] Update `cluster/apps/<service>/kustomization.yaml`.
- [ ] T013 [P] [US1] Define RBAC/secret changes under `cluster/policies/`.
- [ ] T014 [US1] Provide runbook updates in `docs/runbooks/<service>.md`.
- [ ] T015 [US1] Update GitOps controller sync configuration if needed.
- [ ] T016 [US1] Record observability changes in spec/tasks for reviewer sign-off.

**Checkpoint**: Workload deployed via GitOps with validated health/alerts.

---

## Phase 4: Service Workload 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T018 [P] [US2] Update diff/assertions for secondary workload.
- [ ] T019 [P] [US2] Add alert validation for new metrics.

### Implementation for User Story 2

- [ ] T020 [P] [US2] Adjust overlays in `cluster/apps/<service2>/`.
- [ ] T021 [US2] Update sealed secrets or encrypted manifests.
- [ ] T022 [US2] Extend runbook coverage and cross-reference dependencies.

**Checkpoint**: Workload 1 and 2 independently deliver value with GitOps audit trail.

---

## Phase 5: Service Workload 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Harden operations and complete compliance steps.

- [ ] TXXX [P] Rotate credentials/secrets touched by this feature.
- [ ] TXXX Confirm CI pipelines and GitOps sync intervals still succeed.
- [ ] TXXX Update governance review notes with compliance evidence.
- [ ] TXXX Execute runbook validation from `docs/quickstart.md`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **GitOps & Documentation (Phase 1)**: No dependencies - can start immediately
- **Provisioning & Node Health (Phase 2)**: Depends on Phase 1 completion - BLOCKS all user stories
- **Service Workloads (Phase 3+)**: All depend on Phase 2 completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Phase 2 completes; no dependency on other stories.
- **User Story 2 (P2)**: Can start after Phase 2; may integrate with US1 but must stay independently testable.
- **User Story 3 (P3)**: Can start after Phase 2; may integrate with US1/US2 but must stay independently testable.

### Within Each User Story

- Diff/dry-run evidence MUST exist before applying manifests.
- Secrets and RBAC updates MUST be merged only after reviewers confirm scope.
- Runbook documentation MUST be drafted alongside manifest changes.
- Monitoring/alert updates MUST be validated before declaring the story complete.

### Parallel Opportunities

- All Phase 1 tasks marked [P] can run in parallel (docs, base manifests, governance notes)
- All Phase 2 tasks marked [P] can run in parallel (idempotence checks per playbook)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Manifests/overlays within a story marked [P] can run in parallel when touching separate services
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch dry-run checks for User Story 1 together (if requested):
Task: "Run kubectl diff for cluster/apps/<service>"
Task: "Run ansible-playbook --check for automation/ansible/<playbook>.yml"

# Launch all observability updates for User Story 1 together:
Task: "Validate alert rules in tests/k8s-diff/test_alerts.sh"
Task: "Update logging dashboards in cluster/apps/<service>/monitoring.yaml"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: GitOps & Documentation Foundations
2. Complete Phase 2: Provisioning & Node Health (blocks workload phases)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Phases 1 + 2 → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Phases 1 + 2 together
2. Once Phase 2 is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
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
