# pi-k3s Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-10-29

## Using Serena MCP Tool

This project has been onboarded with the Serena MCP tool. Use `mcp__serena__` commands to access and store project information. The serena memories complement the documentation in the `./doc` directory.

- You must use serena tools where possible.
- You'll have to read/update serena memory.
- You must not use built-in read / write tool, except that you may use the Read internal tool to read a file when the user explicitly provides its path and the file cannot be located through Serena tooling.
- You must not use bash to search lines, symbols. Just update serena memory and use serena tools.

## Active Technologies

- Bash automation [EXTRACTED FROM ALL PLAN.MD FILES] Ansible 2.16+, Kubernetes manifests for k3s v1.29 (stable channel) + k3s (embedded etcd), Helm 3.x, Ansible collections (`community.general`, `kubernetes.core`), Mozilla SOPS + age for secrets, kube-prometheus-stack for observability (001-deploy-pi-k3s)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Bash automation [ONLY COMMANDS FOR ACTIVE TECHNOLOGIES] Ansible 2.16+, Kubernetes manifests for k3s v1.29 (stable channel)

## Code Style

Bash automation [LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE] Ansible 2.16+, Kubernetes manifests for k3s v1.29 (stable channel): Follow standard conventions

## Recent Changes

- 001-deploy-pi-k3s: Added Bash automation [LAST 3 FEATURES AND WHAT THEY ADDED] Ansible 2.16+, Kubernetes manifests for k3s v1.29 (stable channel) + k3s (embedded etcd), Helm 3.x, Ansible collections (`community.general`, `kubernetes.core`), Mozilla SOPS + age for secrets, kube-prometheus-stack for observability

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
