# ADR-005 — Recuperar ou reconstruir o SRVAD2025

- **Status:** Proposed
- **Data:** 2026-08-07
- **Incidente:** INC-20260807

## Contexto

O `SRVAD2025` foi promovido com sucesso como DC adicional e GC, porém não iniciou após o reboot. O `SRVAD2022` permanece saudável e possui backup completo recente. O novo DC ainda não hospeda FSMO ou aplicações exclusivas conhecidas.

## Opção A — Recuperar a instalação

### Benefícios

- preserva o trabalho já executado;
- permite identificar a causa raiz do boot;
- evita metadata cleanup.

### Riscos/custos

- tempo de investigação imprevisível;
- alterações de boot podem aumentar a complexidade;
- cada tentativa exige controle rigoroso para não afetar a identidade do DC.

## Opção B — Limpar metadados e reconstruir

### Benefícios

- caminho possivelmente mais rápido para uma VM recém-criada;
- oportunidade de validar UEFI, Secure Boot e reboot antes da nova promoção;
- execução repetível usando checklist aprimorado.

### Riscos/custos

- metadata cleanup é destrutivo e deve atingir exatamente o novo DC;
- a VM antiga nunca poderá voltar à rede depois da limpeza;
- DNS, Sites and Services e replicação precisam ser validados após a remoção.

## Recomendação preliminar

Se todos os FSMO estiverem no `SRVAD2022` e não houver dados exclusivos no `SRVAD2025`, favorecer **Opção B — reconstruir**, após aprovação explícita e backup validado.

## Decisão

Preencher:

- opção escolhida;
- responsável;
- data/hora;
- justificativa;
- riscos aceitos;
- plano de rollback aplicável.

## Resultado

Preencher após a execução e vincular ao commit correspondente.

