# ADR-004: Zabbix Agent 2 com checks ativos

## Status

Aceito.

## Decisão

Usar Zabbix Agent 2 7.0.29 com checks ativos para `192.168.50.20:30051`.

## Motivo

Evita listener e regra de entrada na porta 10050, simplificando o monitoramento durante a migração.

