#!/usr/bin/env bash
set -euo pipefail

VMID="${VMID:-700}"
NAME="${NAME:-pfsense-migracao}"
STORAGE="${STORAGE:-local-lvm}"
ISO="${ISO:-local:iso/pfSense-CE-2.7.2-RELEASE-amd64.iso}"

if qm status "$VMID" >/dev/null 2>&1; then
  echo "VMID $VMID já existe; nenhuma alteração realizada."
  exit 1
fi

if ! pvesm path "$ISO" >/dev/null 2>&1; then
  echo "ISO não encontrada: $ISO"
  exit 1
fi

ip link show vmbr0 >/dev/null
ip link show vmbr10 >/dev/null

qm create "$VMID" \
  --name "$NAME" \
  --description "pfSense UEFI para migração controlada" \
  --machine q35 \
  --bios ovmf \
  --ostype other \
  --cpu host \
  --sockets 1 \
  --cores 2 \
  --memory 2048 \
  --balloon 0 \
  --scsihw virtio-scsi-single \
  --efidisk0 "$STORAGE:0,efitype=4m,pre-enrolled-keys=0" \
  --scsi0 "$STORAGE:20,discard=on,iothread=1,ssd=1" \
  --ide2 "$ISO,media=cdrom" \
  --net0 "virtio,bridge=vmbr0,firewall=0,link_down=1" \
  --net1 "virtio,bridge=vmbr10,firewall=0" \
  --boot "order=ide2;scsi0" \
  --onboot 0 \
  --tablet 0

qm config "$VMID"

