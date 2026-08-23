# ADR-007 — Backup SMB por guest e evolução para PBS

- **Status:** Aceito como solução transitória
- **Data:** 2026-08-16

## Contexto

O storage local do Proxmox não deve ser usado como única proteção das VMs. Um computador na rede dispõe de volume SMB para receber cópias externas, porém a capacidade restante é limitada e o equipamento não é um appliance de backup dedicado.

## Decisão

- Usar um único compartilhamento `PVE-BACKUP`.
- Separar cada guest em subdiretório no formato `<VMID>-<nome>`.
- Criar storage Proxmox específico apontando para o subdiretório do guest.
- Não versionar credenciais ou arquivos de backup.
- Tratar a solução como transitória e planejar disco dedicado ou Proxmox Backup Server.

## Consequências

### Positivas

- organização e identificação simples por VMID;
- isolamento lógico entre os artefatos;
- restauração e retenção mais fáceis de auditar;
- backups fora do storage que executa a VM.

### Limitações

- SMB não fornece, sozinho, imutabilidade ou proteção contra falha do computador de destino;
- capacidade disponível exige retenção controlada;
- múltiplos storages CIFS podem aumentar a administração;
- teste real de restauração continua obrigatório.
