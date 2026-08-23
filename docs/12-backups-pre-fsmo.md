# Backups pré-FSMO do SRVAD2025

## Objetivo

Estabelecer pontos de recuperação independentes antes de transferir qualquer função FSMO para o `SRVAD2025`.

## Camadas concluídas

| Camada | Método | Estado |
|---|---|---|
| VM online | Proxmox `vzdump`, modo snapshot, QEMU Guest Agent e Zstandard | Concluído |
| VM desligada | Proxmox `vzdump`, modo stop/cold e Zstandard | Concluído |
| Active Directory | Windows Server Backup — System State | Concluído |

## Destino externo

Os backups foram armazenados em compartilhamento SMB externo ao host Proxmox. O destino apresentou aproximadamente 200 GiB disponíveis antes da execução.

Não registrar neste repositório usuário, senha ou material de autenticação do compartilhamento.

## Backup online consistente

- VMID: `750`.
- Disco do sistema: 80 GiB.
- EFI Disk incluído.
- QEMU Guest Agent respondeu ao Proxmox.
- `fs-freeze` e `fs-thaw` foram executados.
- Arquivo final compactado: aproximadamente 11,74 GiB.
- Duração aproximada: 5 minutos e 41 segundos.
- Teste `zstd -t`: aprovado.

## Backup cold

- Executado com a VM desligada.
- Disco e EFI incluídos.
- Arquivo final compactado: aproximadamente 11,68 GiB.
- Job concluído com sucesso.

## System State

O Windows Server Backup confirmou:

- backup do volume do sistema;
- System Writer;
- DFS Replication service writer/SYSVOL;
- NTDS;
- Registry Writer;
- conclusão sem erro.

O catálogo `wbadmin` confirmou capacidade de recuperação de Volume, File, Application e System State. O backup ocupou aproximadamente 17,5 GiB no destino externo.

## Atualização — 2026-08-16

Uma nova rodada foi concluída antes da futura transferência FSMO:

| Artefato | Identificação | Resultado |
|---|---|---|
| VM 750 | `vzdump-qemu-750-2026_08_16-03_00_25.vma.zst` | 18.660.430.139 bytes; job e `zstd -t` aprovados |
| System State | versão `08/16/2026-04:45` | EFI, volume C:, AD/NTDS, SYSVOL e Registry catalogados |

Os backups anteriores de 2026-08-08 foram preservados. O destino foi reorganizado sob o compartilhamento `PVE-BACKUP`, no subdiretório `750-srvad2025`.

## Validação mínima antes de FSMO

```powershell
wbadmin get versions
wbadmin get items -version:<IDENTIFICADOR>
```

```bash
pvesm list <STORAGE-ID> --content backup | grep 750
zstd -t <ARQUIVO-VMA-ZST>
```

## Restrições

- Não armazenar backups no Git.
- Não usar snapshot como substituto permanente do System State.
- Não ligar uma restauração clonada do DC na mesma rede sem plano de recuperação.
- Preservar os backups pré-FSMO até concluir a estabilização e validar restauração em procedimento separado.
- A validação por catálogo e `zstd -t` confirma legibilidade; não substitui um teste real de restauração isolada.
