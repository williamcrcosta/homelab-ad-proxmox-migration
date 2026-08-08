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
