# Armazenamento de backup SMB por guest

## Objetivo

Padronizar o destino externo dos backups do Proxmox, isolando cada VM ou container em seu próprio subdiretório e preservando a possibilidade de migração futura para um storage dedicado.

## Estado atual

| Item | Valor |
|---|---|
| Servidor SMB | `192.168.50.9` |
| Raiz local | `D:\pve-backup` |
| Compartilhamento | `PVE-BACKUP` |
| VM protegida | `750-srvad2025` |
| Storage Proxmox | `backup-750-srvad2025` |
| Origem CIFS | `//192.168.50.9/PVE-BACKUP/750-srvad2025` |
| Conteúdo | Backup |

As credenciais SMB não são armazenadas neste repositório.

## Estrutura planejada

```text
D:\pve-backup\
├── 101-ca-server\
├── 201-rtmp-hxc-cameras\
├── 300-pfsense-fw\
├── 400-adguard\
├── 500-rke2-cp-01\
├── 501-rke2-worker-01\
├── 700-pfsense-fw01\
└── 750-srvad2025\
    ├── dump\
    ├── systemstate-20260808\
    └── systemstate-20260816\
```

A existência do diretório não significa que o guest já tenha política de backup. Novos jobs só devem ser ativados depois de dimensionar volume, retenção e janela.

## Validação operacional

```bash
pvesm status | grep backup-750-srvad2025
pvesm list backup-750-srvad2025 --content backup | grep 750
findmnt /mnt/pve/backup-750-srvad2025
```

O resultado final confirmou o storage ativo, CIFS 3.1.1 montado e três backups da VM 750 visíveis no catálogo.

## Limpeza do destino antigo

O compartilhamento anterior `PVE-SRVAD2025` foi removido após a migração. Um mount CIFS residual continuou tentando reconectar e gerou `reconnect tcon failed rc = -2`.

A correção consistiu em desmontar o mount antigo, confirmar ausência de referências em `storage.cfg`, `fstab` e units do systemd, e remover apenas o diretório vazio legado. Depois disso, permaneceu somente o mount `PVE-BACKUP/750-srvad2025`, sem novos eventos CIFS na janela de observação.

## Capacidade e retenção

Após a reorganização, o destino estava com aproximadamente 87% de ocupação e cerca de 120 GiB livres. Isso é suficiente para manter os artefatos atuais, mas não para habilitar backups irrestritos de todos os guests.

Antes de ampliar a cobertura:

1. inventariar o espaço realmente utilizado por cada guest;
2. definir retenção por criticidade;
3. reservar margem para crescimento e falha de um job;
4. testar restauração em rede isolada;
5. manter ao menos uma cópia fora do computador que hospeda o compartilhamento.

## Evolução recomendada

O SMB atual é uma solução transitória. A evolução preferencial é um disco físico dedicado em equipamento sempre ligado e, quando possível, Proxmox Backup Server para incrementais, deduplicação, verificação, prune e garbage collection. A meta de longo prazo é aproximar a proteção da regra 3-2-1.
