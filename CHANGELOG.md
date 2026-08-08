# Changelog

## 2026-08-07

- Limpeza do controlador antigo `SRVAD2019` concluída.
- Microsoft Entra Connect atualizado e sincronização recuperada.
- Proxmox inventariado e bridges `vmbr0`/`vmbr10` definidas.
- pfSense novo e Windows Server 2025 criados em UEFI.
- IPsec IKEv2 entre as redes `10.100.10.0/24` e `10.100.20.0/24` estabelecido.
- RPC 135 e SMB 445 validados através do túnel.
- `SRVAD2025` ingressado no domínio `wcrpc.lan`.
- Horário do `SRVAD2025` sincronizado com `SRVAD2022`.
- Zabbix Agent 2 7.0.29 instalado no `SRVAD2025`.

## 2026-08-07/08 — Promoção do SRVAD2025 e recuperação do SYSVOL

### Adicionado

- Windows Server 2025 Standard implantado no Proxmox como `SRVAD2025`.
- VM UEFI/Q35, VMID 750, conectada à rede isolada `10.100.20.0/24`.
- Túnel IPsec entre as redes antiga e nova.
- Novo DC promovido com DNS e Global Catalog.
- ADR para uso do modelo de CPU `x86-64-v2-AES`.
- Script de auditoria pós-recuperação do SYSVOL.

### Corrigido

- Ciclo de reinicialização do Windows Server 2025 após promoção, resolvido com a troca de `cpu: host` para `x86-64-v2-AES`.
- Bloqueio de sincronização do SYSVOL com ambos os DCs em DFSR `State 2`.
- `SRVAD2022` recuperado como membro autoritativo, confirmado pelo evento `4602`.
- `SRVAD2025` recuperado como membro não autoritativo, confirmado pelo evento `4604`.
- Compartilhamentos `SYSVOL` e `NETLOGON` publicados nos dois DCs.
- Testes `Advertising`, `SysVolCheck`, `NetLogons` e `DNS` aprovados no novo DC.

### Pendente

- Período de observação da replicação.
- Auditoria pós-promoção completa.
- Backup do novo DC.
- Planejamento de FSMO e Microsoft Entra Connect.

