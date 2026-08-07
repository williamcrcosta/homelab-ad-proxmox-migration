# INC-20260807 — Falha de boot após promoção do SRVAD2025

## Estado

**Aberto — causa raiz ainda em investigação.**

Não executar nova promoção, restauração de snapshot ou exclusão da VM até escolher formalmente entre recuperação e reconstrução controlada.

## Resumo executivo

O servidor `SRVAD2025` (`10.100.20.10`) foi preparado como controlador de domínio adicional para `wcrpc.lan`. Todos os pré-requisitos passaram, a promoção replicou as partições e terminou com código zero. No primeiro reboot como DC, o Windows entrou em ciclo de recuperação e não carregou nem em Directory Services Repair Mode.

O controlador existente `SRVAD2022` (`10.100.10.11`) permaneceu operacional, com AD DS, DNS e Microsoft Entra Connect funcionais. O novo DC aparece no diretório como Global Catalog, mas está offline e gera falhas de replicação/DNS.

## Impacto

- `SRVAD2022` continua atendendo autenticação, DNS e Entra Connect.
- `SRVAD2025` indisponível após a promoção.
- Replicação para/de `SRVAD2025` falha enquanto a VM permanece offline.
- Não há indicação atual de perda de dados no DC existente.

## Topologia relevante

| Componente | Endereço | Função |
|---|---:|---|
| SRVAD2022 | 10.100.10.11 | DC existente, DNS, GC e Entra Connect |
| pfSense antigo | 192.168.50.15 / 10.100.10.1 | Gateway da LAN10 |
| pfSense novo | 192.168.50.16 / 10.100.20.1 | Gateway da LAN20 |
| SRVAD2025 | 10.100.20.10 | Novo DC promovido, atualmente offline |
| Proxmox | 192.168.50.250 | Hypervisor da VM 750 |

As redes `10.100.10.0/24` e `10.100.20.0/24` são interligadas por IPsec IKEv2 entre os dois pfSense.

## Pré-validações concluídas

- DNS do `SRVAD2025`: somente `10.100.10.11`.
- Resolução de `_ldap._tcp.dc._msdcs.wcrpc.lan`: sucesso.
- Horário: sincronizado com `srvad2022.wcrpc.lan`.
- Canal seguro do domínio: validado antes da promoção.
- Portas TCP `53, 88, 135, 389, 445, 464, 636, 3268, 3269, 9389`: sucesso.
- AD DS e DNS: instalados no `SRVAD2025`.
- `Test-ADDSDomainControllerInstallation`: sucesso.
- Backup do `SRVAD2022` de 07/08/2026 10:19: validado e legível, contendo AD/NTDS, SYSVOL, Registry, volumes e Bare Metal Recovery.
- Microsoft Entra Connect: ciclos Delta Import, Delta Synchronization e Export concluídos com `success`.

## Linha do tempo

| Horário aproximado | Evento |
|---|---|
| Antes da promoção | Backup e pré-requisitos validados |
| 16:28:24 | Replicação inicial das partições do domínio concluída |
| 16:28:24 | `The attempted domain controller operation has completed` |
| 16:28:24 | `DsRolepSetOperationDone returned 0` |
| Após o reboot | Windows passa a entrar no ambiente de recuperação |
| Diagnóstico | BCD aponta para `partition=C:` e `winload.efi` |
| Diagnóstico | `chkdsk C:` não encontrou erros |
| Diagnóstico | Não foram encontrados `Minidump`, `MEMORY.DMP` ou `ntbtlog.txt` |
| 17:31:50 | `repadmin` no DC existente registra falhas de replicação |

## Evidências técnicas

### Promoção

O `dcpromo.log` registrou:

```text
Replication data DC=wcrpc,DC=lan: received 1842 out of approximately 1842 objects
Replicating DC=DomainDnsZones,DC=wcrpc,DC=lan: received 25 out of approximately 25 objects
Replicating DC=ForestDnsZones,DC=wcrpc,DC=lan: received 20 out of approximately 20 objects
The attempted domain controller operation has completed
DsRolepSetOperationDone returned 0
```

### Estado do diretório visto pelo SRVAD2022

```text
srvad2022.wcrpc.lan  10.100.10.11  Default-First-Site-Name  GC=True
SRVAD2025.wcrpc.lan  10.100.20.10  Default-First-Site-Name  GC=True
```

### Replicação

`repadmin /showrepl` registrou cinco falhas consecutivas desde a promoção:

```text
Last error: 8524 (0x214c)
The DSA operation is unable to proceed because of a DNS lookup failure.
```

O erro é consistente com um DC promovido que está offline antes de completar o registro/replicação DNS pós-reboot.

## Constatações

1. A promoção não falhou no estágio do DCPromo; ela terminou com retorno zero.
2. O disco NTFS e o BCD foram encontrados e estão legíveis.
3. A falha acontece no primeiro boot como DC ou durante uma reinicialização imediatamente subsequente.
4. A mensagem UEFI observada após o círculo de boot pode ser consequência do reinício, e não necessariamente a causa original.
5. O `SRVAD2022` permanece a fonte confiável e não deve ser removido ou alterado durante a investigação.

## Hipóteses em aberto

- falha muito precoce do Windows antes da gravação do Event Log;
- problema de boot/UEFI/Secure Boot após o primeiro reinício;
- alteração pendente de sistema ou driver;
- falha específica da inicialização do DC que ocorre antes da criação dos logs esperados.

Nenhuma hipótese deve ser registrada como causa raiz sem evidência adicional.

## Salvaguardas

- Não ligar uma cópia restaurada da VM simultaneamente à identidade atual do DC.
- Não executar novamente `Install-ADDSDomainController`.
- Não apagar a VM antes da limpeza de metadados, caso a reconstrução seja escolhida.
- Não remover o `SRVAD2022`.
- Confirmar FSMO no `SRVAD2022` antes de qualquer limpeza.
- Manter export recente das configurações dos dois pfSense.

## Próxima decisão

Registrar a escolha e a justificativa em `decisions/ADR-005-recover-or-rebuild-srvad2025.md`.

## Encerramento

Preencher após a resolução:

- causa raiz;
- correção aplicada;
- horário de restauração;
- validações pós-correção;
- ações preventivas;
- links para commits e evidências.

