# Proxmox e máquinas virtuais

## VM 700 — pfSense

- BIOS: OVMF/UEFI.
- Machine: q35.
- CPU: 2 vCPU, tipo `host`.
- Memória: 2 GiB.
- Disco: 20 GiB, VirtIO SCSI.
- WAN: `vmbr0`.
- LAN: `vmbr10`.
- Secure Boot: desativado.
- Filesystem do guest: UFS/GPT.

## VM 750 — Windows Server 2025

- Windows Server 2025 Standard Desktop Experience.
- BIOS: OVMF/UEFI com chaves Microsoft 2023.
- Machine: q35.
- CPU: 2 vCPU, tipo `host`.
- Memória temporária: 6 GiB; redução será avaliada após promoção.
- Disco: 80 GiB, VirtIO SCSI.
- NIC: VirtIO em `vmbr10`.
- QEMU Guest Agent habilitado.

