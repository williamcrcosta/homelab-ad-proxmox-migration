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

