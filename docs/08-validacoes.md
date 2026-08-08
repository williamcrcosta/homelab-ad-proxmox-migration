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
