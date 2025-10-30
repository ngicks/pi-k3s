# Hardware & Environment Requirements

## Nodes
- Four Raspberry Pi 4 Model B (8GB RAM) with reliable SSD or high-endurance SD storage.
- Hostnames: `pi-cluster-1.local` … `pi-cluster-4.local` (unique mDNS entries).
- Local console or out-of-band access for recovery.

## Networking
- Wired Gigabit Ethernet connection for each node.
- Static IP reservations or documented DHCP leases matching the hostnames.
- Reliable router/switch with VLAN and QoS documented if applicable.

## Power & Cooling
- Stable power (PoE or conditioned supply) with surge protection.
- Adequate cooling (heat sinks/fans) to sustain sustained workloads.
- UPS recommended for control-plane nodes.

## Workstation Requirements
- Python 3.11+ with uv-managed virtual environment.
- kubectl 1.29+, helm 3.14+, sops, age.
- SSH access to nodes via an account referenced by `K3S_SSH_USER`.

## Miscellaneous
- Documented inventory of cables, spare storage media, and replacement parts.
- Backup location for age keys and kubeconfig artifacts.
