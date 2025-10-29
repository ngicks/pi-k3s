# Research Log: Set Up Pi k3s Cluster

## Raspberry Pi OS Preparation
- **Decision**: Use Raspberry Pi OS Lite 64-bit (Debian Bookworm) with cgroups v2 enabled, swap disabled, and container-friendly sysctl tuning applied via Ansible `base_os` role.
- **Rationale**: Aligns with k3s HA support matrix, minimizes resource overhead, and allows reproducible node prep through automation.
- **Alternatives considered**: Ubuntu Server 22.04 LTS (heavier footprint, longer boot times); HypriotOS (less actively maintained for HA scenarios).

## k3s HA Topology
- **Decision**: Configure nodes 1–3 as k3s server+agent members sharing embedded etcd; designate node 4 as worker-only while tolerating workloads from control-plane nodes when necessary.
- **Rationale**: Three servers meet etcd quorum, retain agent scheduling locally, and leave a dedicated worker for capacity validation.
- **Alternatives considered**: External etcd with all nodes as workers (adds ops burden); two-server HA (risk of split-brain; no quorum if one fails).

## Secrets Encryption Workflow
- **Decision**: Manage sensitive manifests with Mozilla SOPS using age key pairs stored offline; integrate with Ansible via `community.sops` lookup to decrypt during deployment.
- **Rationale**: SOPS natively supports Git-based workflows, age keys are lightweight to manage, and tooling runs cross-platform for operators.
- **Alternatives considered**: Sealed Secrets (requires controller workload); HashiCorp Vault (overkill for four-node lab, adds maintenance overhead).

## Network & Load Balancing
- **Decision**: Retain k3s default flannel CNI with vxlan backend and embedded servicelb; document IP reservations and optional MetalLB configuration for future expansion.
- **Rationale**: Defaults minimize tuning, work well on constrained hardware, and satisfy immediate HA testing goals; future MetalLB steps captured for scalability.
- **Alternatives considered**: Calico (richer policy features but heavier); Cilium (requires BPF tuning, more complex on Pi OS).

## Observability Stack
- **Decision**: Deploy kube-prometheus-stack (Prometheus, Alertmanager, Grafana) plus Loki for log aggregation via Helm charts applied manually.
- **Rationale**: Provides end-to-end metrics, logs, and dashboards with strong arm64 support and well-known runbooks.
- **Alternatives considered**: Lightweight Prometheus/operator pairing without dashboards (less visibility); Netdata (good metrics but limited alerting integration).

## Manual Deployment Evidence Workflow
- **Decision**: Require operators to run `kubectl diff`/`helm diff` before applies, capture output in PR artifacts, and log manual interventions in `docs/governance/reviews/`.
- **Rationale**: Upholds GitOps principle without dedicated controller, ensuring auditability and reproducibility of manual actions.
- **Alternatives considered**: Fully automated FluxCD/Argo CD (heavier footprint, skipped per operator preference); manual applies without diff logging (violates constitution).

## Storage Strategy
- **Decision**: Use k3s local-path provisioner for persistent volumes with SSD-backed storage; document optional integration path for Longhorn in future iterations.
- **Rationale**: Local-path is default, minimal overhead, and sufficient for HA testing; Longhorn can be evaluated later when storage redundancy becomes priority.
- **Alternatives considered**: NFS share (adds external dependency); Longhorn immediately (requires more resources and tuning).

## Runbook Scope
- **Decision**: Author/update runbooks for bootstrap, HA failover recovery, node rebuild drills, secrets rotation, observability verification, and manual apply SOP.
- **Rationale**: Maps directly to constitution documentation requirements and ensures operators can execute procedures consistently.
- **Alternatives considered**: Ad-hoc wiki notes (risk of drift); video walkthroughs only (hard to automate/review).
