## 2026-08-07 — Primeiro ensaio de promoção do SRVAD2025

### Adicionado

- Pré-auditoria dos servidores antes da promoção.
- Validação do backup de System State do `SRVAD2022`.
- Validação do Microsoft Entra Connect após correção de resolução DNS externa.
- Promoção do `SRVAD2025` como DC adicional e Global Catalog.
- Registro do incidente `INC-20260807`.

### Resultado

- DCPromo concluiu a replicação inicial e retornou código zero.
- `SRVAD2025` não iniciou após o primeiro reboot como DC.
- `SRVAD2022` permaneceu operacional.
- Investigação confirmou BCD legível e volume sem erros de sistema de arquivos.
- Diretório registra o novo DC, atualmente offline, com erro de replicação 8524 relacionado a DNS.

### Pendente

- Decisão ADR-005: recuperar ou reconstruir o `SRVAD2025`.
- Identificar causa raiz do boot.
- Executar e documentar validações pós-resolução.
