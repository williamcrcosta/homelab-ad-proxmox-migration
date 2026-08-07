# ADR-002: LAN isolada no vmbr10

## Status

Aceito.

## Decisão

Usar `vmbr10` sem IP no host Proxmox para conectar a LAN do pfSense novo e as VMs da rede `10.100.20.0/24`.

## Consequência

O pfSense controla roteamento, NAT e firewall dessa rede, evitando ligação acidental direta à LAN física.

