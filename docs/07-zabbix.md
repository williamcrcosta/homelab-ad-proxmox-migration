# Zabbix

- Servidor principal: `192.168.50.20`.
- Versão: 7.0.29 LTS.
- Agente: Zabbix Agent 2 7.0.29 para Windows amd64.
- Hostname ativo: `SRVAD2025`.
- Checks ativos: `192.168.50.20:30051`.
- Template recomendado: `Windows by Zabbix agent active`.
- Buffer persistente: habilitado em `C:\ProgramData\Zabbix\zabbix_agent2.db`.

O agente foi configurado para checks ativos, sem listener passivo. Isso evita uma exposição de entrada desnecessária na porta 10050.

