# Inventário

## Proxmox

- PVE 9.2.5, kernel 7.0.14-8-pve.
- CPU Intel Core i7-10750H: 6 cores/12 threads.
- Memória física: 32 GiB.
- Storage principal: `local-lvm` thin pool.
- Rede física: `vmbr0`, `192.168.50.250/24`.
- Rede isolada: `vmbr10`, sem IP no host.

## Máquinas da migração

| VMID | Nome | Plataforma | Função |
|---:|---|---|---|
| 700 | `pfsense-migracao` | pfSense CE | Firewall/roteador da LAN20 |
| 750 | `srvad2025` | Windows Server 2025 Standard | Futuro DC adicional |

## Endereçamento

| Rede | Gateway | Finalidade |
|---|---|---|
| `192.168.50.0/24` | `192.168.50.254` | Rede física/WAN dos pfSense |
| `10.100.10.0/24` | `10.100.10.1` | LAN antiga |
| `10.100.20.0/24` | `10.100.20.1` | LAN nova no Proxmox |

