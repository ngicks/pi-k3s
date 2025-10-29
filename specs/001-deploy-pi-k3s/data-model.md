# Data Model: Set Up Pi k3s Cluster

## Entities

### ClusterNode
- **Identifiers**: `node_id` (string, format `pi-<number>`), unique; `hostname`
- **Attributes**:
  - `role` (enum: `server-agent`, `worker`)
  - `hardware_profile` (CPU, RAM, storage type)
  - `ip_address` (static or DHCP reservation)
  - `labels` (map<string,string>)
  - `taints` (list of `{key, effect}`)
  - `last_rebuild_at` (timestamp)
  - `ansible_inventory_group` (string)
- **Relationships**: One-to-many with `ProvisioningRun` (node participates in many runs).
- **Validation Rules**: Workers must not hold `control-plane` taint; server-agent nodes must have unique etcd peer addresses.

### ProvisioningRun
- **Identifiers**: `run_id` (UUID)
- **Attributes**:
  - `trigger_type` (enum: `bootstrap`, `rebuild`, `upgrade`)
  - `initiated_by` (operator id)
  - `started_at` / `completed_at`
  - `duration_minutes`
  - `status` (enum: `pending`, `success`, `failed`)
  - `ansible_commit` (git SHA of playbooks)
  - `diff_artifacts_path` (repo path to stored diffs/logs)
- **Relationships**: Many-to-many with `ClusterNode` via join table `ProvisioningRunNode`; optional one-to-one with `SecretsRotation` when rotation performed in same run.
- **Validation Rules**: `duration_minutes` MUST be ≤60 for rebuild success per success criteria; failed runs require linked incident record.

### ConfigurationChange
- **Identifiers**: `change_id` (UUID)
- **Attributes**:
  - `feature_branch` (string)
  - `manifest_paths` (list of relative paths)
  - `diff_summary` (short text)
  - `applied_at` (timestamp)
  - `approved_by` (list of reviewer ids)
  - `runbook_updates` (list of doc references)
  - `status` (enum: `draft`, `pending-review`, `applied`, `rolled-back`)
- **Relationships**: One-to-many with `ManualApplyEvidence`; optional link to `ProvisioningRun` when change includes automation update.
- **Validation Rules**: Applied changes must include at least one diff artifact and a runbook reference; rolled-back status requires rollback summary.

### ManualApplyEvidence
- **Identifiers**: `evidence_id` (UUID)
- **Attributes**:
  - `command` (`kubectl diff`, `helm diff`, etc.)
  - `output_path` (artifact location)
  - `timestamp`
  - `operator_id`
- **Relationships**: Belongs to `ConfigurationChange`.
- **Validation Rules**: Evidence must be recorded before corresponding apply action is executed.

### SecretsRotation
- **Identifiers**: `rotation_id` (UUID)
- **Attributes**:
  - `rotation_scope` (e.g., `kubeconfig`, `registry`, `alertmanager`)
  - `age_key_fingerprint`
  - `initiated_at` / `completed_at`
  - `verification_steps` (list)
  - `next_rotation_due`
- **Relationships**: Optional link to `ProvisioningRun` when rotation happens during automation.
- **Validation Rules**: `next_rotation_due` set within 90 days; verification steps must include successful redeploy confirmation.

### AlertRoute
- **Identifiers**: `route_id` (UUID)
- **Attributes**:
  - `alert_name`
  - `severity` (`critical`, `warning`)
  - `channel` (`pager`, `matrix`, `email`)
  - `acknowledgement_target` (operator group)
  - `last_tested_at`
- **Relationships**: Associated with `ConfigurationChange` when alert definitions change.
- **Validation Rules**: `last_tested_at` must be within 30 days for critical severity routes.

## Relationships Overview
- `ClusterNode` ←→ `ProvisioningRun`: tracked via `ProvisioningRunNode` join entity capturing node role during run.
- `ConfigurationChange` → `ManualApplyEvidence`: each change holds one or more evidence artifacts.
- `ProvisioningRun` ↔ `SecretsRotation`: optional linkage when secrets rotate as part of automation.
- `ConfigurationChange` → `AlertRoute`: updates to alerts create or modify routes recorded in governance.

## State Transitions
- `ProvisioningRun.status`: `pending` → `success`/`failed`; failures require remediation plan before rerun.
- `ConfigurationChange.status`: `draft` → `pending-review` → `applied`; optionally `rolled-back` with incident reference.
- `SecretsRotation`: `scheduled` → `in-progress` → `verified`; missing verification reverts to `scheduled` with follow-up task.

## Data Volume & Retention
- Expect ≤10 nodes, each with quarterly rebuild runs; store provisioning history for at least 1 year.
- Manual apply evidence retained indefinitely within repository history to satisfy audit requirements.
- Alert routes reviewed quarterly; obsolete routes archived but not deleted to preserve incident correlation.
