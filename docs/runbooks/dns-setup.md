# Internal DNS Server Setup and Operations

## Overview

The pi-k3s cluster uses a dedicated internal DNS server (Unbound) running on `dns-internal-1.home.arpa` (192.168.10.254) to provide:
- Forward DNS resolution for cluster nodes (`.home.arpa` domain)
- Reverse DNS (PTR records) for all cluster IPs
- HA DNS aliases with round-robin load distribution (`k3s-api.home.arpa`, `*.apps.home.arpa`)
- DNS forwarding to upstream router (192.168.10.1) for external queries

**Domain**: `home.arpa` (RFC 8375 compliant for home networks)
**DNS Software**: Unbound
**Configuration Management**: Ansible role `internal_dns`

## DNS Records

### Forward DNS (A Records)

| Hostname | IP Address | Purpose |
|----------|------------|---------|
| `pi-cluster-1.home.arpa` | 192.168.10.250 | Control plane node 1 (server+agent) |
| `pi-cluster-2.home.arpa` | 192.168.10.249 | Control plane node 2 (server+agent) |
| `pi-cluster-3.home.arpa` | 192.168.10.248 | Control plane node 3 (server+agent) |
| `pi-cluster-4.home.arpa` | 192.168.10.247 | Worker node (agent only) |
| `dns-internal-1.home.arpa` | 192.168.10.254 | Internal DNS server |

### HA Service Aliases (Round-Robin)

| Service Alias | Target IPs | Purpose |
|---------------|------------|---------|
| `k3s-api.home.arpa` | 192.168.10.250, 249, 248 | K3s API endpoint (HA across control plane) |
| `*.apps.home.arpa` | 192.168.10.250, 249, 248 | Wildcard for ingress controller |

### Reverse DNS (PTR Records)

All cluster node IPs have corresponding PTR records mapping back to their `.home.arpa` hostnames.

## Initial Setup

### Prerequisites

1. DNS server node (`dns-internal-1.home.arpa`) must have static IP configured via netplan
2. Router at 192.168.10.1 must be reachable for DNS forwarding
3. Ansible control machine has access to the DNS node

### Provisioning Steps

1. **Verify network configuration**:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/network.yaml --limit internal_dns --check
   ```

2. **Provision DNS server** (dry-run first):
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/dns.yaml --check
   ```

3. **Apply DNS configuration**:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/dns.yaml
   ```

4. **Update all cluster nodes to use internal DNS**:
   ```bash
   # First, verify the change (review netplan diffs)
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/network.yaml --check

   # Apply the network changes (nodes will reboot if netplan changes)
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/network.yaml
   ```

5. **Validate DNS resolution from a cluster node**:
   ```bash
   ssh pi-cluster-1.home.arpa
   dig +short k3s-api.home.arpa
   # Should return 3 IPs: 192.168.10.250, 249, 248
   ```

## Operations

### Checking DNS Server Status

```bash
ssh dns-internal-1.home.arpa
sudo systemctl status unbound
```

### Viewing DNS Query Logs

```bash
ssh dns-internal-1.home.arpa
sudo journalctl -u unbound -f
```

### Testing DNS Resolution

```bash
# Test from DNS server itself
dig @127.0.0.1 k3s-api.home.arpa

# Test from cluster node
ssh pi-cluster-1.home.arpa
dig k3s-api.home.arpa

# Test round-robin behavior (run multiple times)
for i in {1..5}; do dig +short k3s-api.home.arpa; echo "---"; done
```

### Validating Unbound Configuration

```bash
ssh dns-internal-1.home.arpa
sudo unbound-checkconf
```

### Restarting DNS Service

```bash
ssh dns-internal-1.home.arpa
sudo systemctl restart unbound
sudo systemctl status unbound
```

## Configuration Changes

### Adding a New DNS Record

1. Edit the role defaults:
   ```bash
   vim automation/ansible/roles/internal_dns/defaults/main.yml
   ```
   Add the new node to `dns_nodes` list.

2. Reapply the DNS configuration:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/dns.yaml
   ```

### Changing DNS Forwarder

1. Edit `automation/ansible/roles/internal_dns/defaults/main.yml`:
   ```yaml
   dns_forwarder: <new_upstream_dns>
   ```

2. Reapply configuration:
   ```bash
   ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/dns.yaml
   ```

## Troubleshooting

### DNS Server Not Responding

1. Check if Unbound is running:
   ```bash
   ssh dns-internal-1.home.arpa
   sudo systemctl status unbound
   ```

2. Check if port 53 is listening:
   ```bash
   sudo ss -tulpn | grep :53
   ```

3. Review Unbound logs:
   ```bash
   sudo journalctl -u unbound --since "10 minutes ago"
   ```

### Resolution Failures

1. Test direct query to DNS server:
   ```bash
   dig @192.168.10.254 pi-cluster-1.home.arpa
   ```

2. Check if client is using correct DNS server:
   ```bash
   ssh pi-cluster-1.home.arpa
   cat /etc/resolv.conf
   # Should show nameserver 192.168.10.254
   ```

3. Validate Unbound configuration:
   ```bash
   ssh dns-internal-1.home.arpa
   sudo unbound-checkconf
   ```

### Round-Robin Not Working

1. Verify Unbound has `rrset-roundrobin: yes`:
   ```bash
   ssh dns-internal-1.home.arpa
   grep rrset-roundrobin /etc/unbound/unbound.conf.d/pi-k3s.conf
   ```

2. Verify multiple A records exist:
   ```bash
   ssh dns-internal-1.home.arpa
   grep "k3s-api" /etc/unbound/unbound.conf.d/local-zone.conf
   # Should show 3 local-data entries
   ```

### Upstream Forwarding Issues

1. Test connectivity to upstream DNS:
   ```bash
   ssh dns-internal-1.home.arpa
   ping 192.168.10.1
   dig @192.168.10.1 google.com
   ```

2. Check Unbound's forward configuration:
   ```bash
   grep forward-addr /etc/unbound/unbound.conf.d/pi-k3s.conf
   ```

## Disaster Recovery

### DNS Server Rebuild

The DNS server can be fully rebuilt from scratch using the Ansible playbook:

```bash
# Reprovision from a clean Ubuntu install
ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/network.yaml --limit internal_dns
ansible-playbook -i automation/ansible/inventory/hosts.yml automation/ansible/dns.yaml
```

**SLO**: DNS server rebuild time < 10 minutes

### Fallback to Router DNS

If the internal DNS server fails, cluster nodes will automatically fall back to the router DNS (192.168.10.1) configured as the secondary nameserver in `/etc/netplan/`.

**Limitation**: Fallback DNS will not resolve `.home.arpa` hostnames, only external queries.

## Governance

### GitOps Evidence

All DNS configuration changes must:
1. Be committed to the repository (role templates and variables)
2. Include `--check` output archived in `docs/governance/reviews/<date>-dns-change/`
3. Link to the governance review in the commit message

### Observability

- **Logs**: Unbound query logs via systemd journal
- **Metrics**: Optional prometheus-unbound-exporter (future enhancement)
- **Alerts**: Monitor DNS resolution failures from cluster nodes

### Security

- **Access Control**: DNS server only accepts queries from 192.168.10.0/24 and localhost
- **DNSSEC**: Not currently enabled (future enhancement)
- **Secrets**: No credentials required for DNS operation

## References

- [Unbound Documentation](https://unbound.docs.nlnetlabs.nl/)
- [RFC 8375: Special-Use Domain 'home.arpa'](https://www.rfc-editor.org/rfc/rfc8375.html)
- Ansible role: `automation/ansible/roles/internal_dns/`
- Network configuration: `automation/ansible/group_vars/all/network.yml`
