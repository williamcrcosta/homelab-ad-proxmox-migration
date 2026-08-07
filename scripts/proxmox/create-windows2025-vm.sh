#!/usr/bin/env bash
set -euo pipefail

VMID="${VMID:-750}"
NAME="${NAME:-srvad2025}"
STORAGE="${STORAGE:-local-lvm}"
WINDOWS_ISO="${WINDOWS_ISO:-local:iso/en-us_windows_server_2025_updated_june_2026_x64_dvd_a2d68429.iso}"
VIRTIO_ISO="${VIRTIO_ISO:-local:iso/virtio-win.iso}"

if qm status "$VMID" >/dev/null 2>&1; then
  echo "VMID $VMID já existe; nenhuma alteração realizada."
  exit 1
fi

for volume in "$WINDOWS_ISO" "$VIRTIO_ISO"; do
  if ! pvesm path "$volume" >/dev/null 2>&1; then
    echo "ISO não encontrada: $volume"
    exit 1
  fi
done

ip link show vmbr10 >/dev/null

qm create "$VMID" \
  --name "$NAME" \
  --description "Windows Server 2025 Standard - futuro DC adicional" \
  --machine q35 \
  --bios ovmf \
  --ostype win11 \
  --cpu host \
  --sockets 1 \
  --cores 2 \
  --memory 6144 \
  --balloon 0 \
  --scsihw virtio-scsi-single \
  --efidisk0 "$STORAGE:0,efitype=4m,pre-enrolled-keys=1" \
  --scsi0 "$STORAGE:80,discard=on,iothread=1,ssd=1" \
  --ide2 "$WINDOWS_ISO,media=cdrom" \
  --sata0 "$VIRTIO_ISO,media=cdrom" \
  --net0 "virtio,bridge=vmbr10,firewall=0" \
  --agent enabled=1 \
  --boot "order=ide2;scsi0" \
  --onboot 0 \
  --tablet 1

qm config "$VMID"

