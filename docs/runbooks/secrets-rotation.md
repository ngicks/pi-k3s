# Secrets Rotation Checklist

- [ ] Identify rotation scope (kubeconfig, registry, alertmanager, etc.).
- [ ] Generate new credentials or tokens.
- [ ] Encrypt updated manifests with SOPS using project age keys.
- [ ] Apply changes via kubectl/helm with diff evidence captured.
- [ ] Verify workloads reconcile without manual intervention.
- [ ] Update rotation log in docs/governance/reviews/.
- [ ] Schedule next rotation date.
