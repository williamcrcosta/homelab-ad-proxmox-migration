# Visão geral

O ambiente original concentrava AD DS, DNS e Microsoft Entra Connect no `SRVAD2022`, hospedado no VMware. A estratégia escolhida foi criar um controlador adicional no Proxmox, validar a replicação e somente depois planejar a migração dos demais papéis.

## Princípios

1. Não clonar nem restaurar snapshot de um DC como método de migração.
2. Manter o DC atual ligado durante a promoção e replicação.
3. Usar DNS interno do AD em todos os membros do domínio.
4. Não mover FSMO nem Entra Connect antes das validações.
5. Manter rollback simples em cada etapa.

