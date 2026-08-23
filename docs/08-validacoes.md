# Validações

## Antes da promoção

Execute `scripts/windows/Test-ADReadiness.ps1` no `SRVAD2025`.

Critérios:

- DNS aponta exclusivamente para `10.100.10.11`.
- Canal seguro do domínio válido.
- DC localizado por `nltest`.
- Portas essenciais acessíveis.
- Horário sincronizado com a hierarquia do domínio.
- Phase 1 e Phase 2 do IPsec estabelecidas.
- Zabbix recebendo métricas recentes.

## Depois da promoção

- `dcdiag /v` sem falhas críticas.
- `repadmin /replsummary` sem erros.
- `repadmin /showrepl` com replicação bem-sucedida.
- Compartilhamentos `SYSVOL` e `NETLOGON` presentes.
- Registros DNS do novo DC registrados.
- Autenticação testada usando ambos os DCs.

## Resultado pós-estabilização — 2026-08-08

| Controle | Resultado |
|---|---|
| DFSR/SYSVOL | `State 4` nos dois DCs |
| SYSVOL/NETLOGON | Publicados nos dois DCs |
| DNS | `dcdiag` aprovado no DC e no domínio |
| Global Catalog | Registros SRV/A presentes nos dois DNS |
| Netlogon | Canal seguro e registro DNS com `NERR_Success` |
| Replicação | Zero falhas nos cinco naming contexts |
| BPA AD DS | 40 Information; 0 Warning; 0 Error |
| BPA DNS | 60 Information; 1 Warning; 1 regra de configuração |
| FSMO | Cinco funções ainda no `SRVAD2022` |

### Exceções aceitas do BPA DNS

- A regra de loopback permaneceu reportada mesmo com DNS remoto preferencial e o IP local como alternativo. A configuração foi mantida porque DNS, DC Locator, GC, Netlogon e replicação foram aprovados.
- Scavenging desabilitado será tratado em mudança futura; não é bloqueador para FSMO.

## Revalidação — 2026-08-16

- Serviços `NTDS`, `DNS`, `DFSR`, `Netlogon`, `KDC` e `W32Time` em execução.
- DFSR/SYSVOL permaneceu em `State 4`.
- `dcdiag` de Advertising, DNS, SysVolCheck e NetLogons aprovado.
- `repadmin /replsummary` retornou zero falhas.
- Novo backup da VM 750 e novo System State concluídos e catalogados.
- Entra Connect: ciclo Delta e conectividade do Health Agent aprovados após limpeza de certificado expirado.

## Validação do storage externo

```bash
pvesm status | grep backup-750-srvad2025
pvesm list backup-750-srvad2025 --content backup | grep 750
findmnt /mnt/pve/backup-750-srvad2025
journalctl -k --since "-10 minutes" --no-pager | grep -Ei 'CIFS|PVE-BACKUP'
```

Critério: storage ativo, backups listados, origem CIFS correta e nenhum erro CIFS novo.
