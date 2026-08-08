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

- Transferência faseada das funções FSMO.
- Planejamento do Microsoft Entra Connect em mudança independente.
- Planejamento de DNS scavenging em mudança independente.

## 2026-08-08 — Estabilização, backup e preparação pré-FSMO

### Validado

- Operação simultânea de `SRVAD2022` e `SRVAD2025` por mais de dez horas.
- DFSR `State 4`, `SysvolReady = 1` e compartilhamentos `SYSVOL`/`NETLOGON` nos dois DCs.
- `dcdiag` de DNS, Advertising, SysVolCheck e NetLogons aprovado no `SRVAD2025`.
- Replicação bidirecional dos cinco naming contexts com zero falhas.
- Registros LDAP e Global Catalog publicados nos DNS `10.100.10.11` e `10.100.20.10`.
- `nltest` para PDC, GC, canal seguro e registro DNS concluído com `NERR_Success`.
- DNS Client do `SRVAD2025`: `10.100.10.11` preferencial e `10.100.20.10` alternativo.
- BPA AD DS: 40 conformidades, zero avisos e zero erros.
- BPA DNS: aviso de scavenging e regra de loopback documentados como não bloqueantes.

### Backup

- Backup online consistente da VM 750 com QEMU Guest Agent e `fs-freeze/fs-thaw`.
- Backup cold da VM 750 concluído com a VM desligada.
- Arquivos VMA/Zstandard armazenados fora do host Proxmox e validados.
- System State do `SRVAD2025` concluído com NTDS, SYSVOL/DFSR e Registry.

### Decisão

- Manter Secure Boot desabilitado até janela de testes específica.
- Manter CPU `x86-64-v2-AES`.
- Transferir FSMO de forma faseada, mantendo o PDC Emulator por último.
