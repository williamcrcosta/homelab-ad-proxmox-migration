# Rollback

## Antes da promoção

1. Não alterar o `SRVAD2022`.
2. Retirar o `SRVAD2025` do domínio se necessário.
3. Desligar a VM 750.
4. Desabilitar a Phase 2/P1 do IPsec novo sem apagar sua definição.

## Durante ou após promoção incompleta

1. Não apagar a VM imediatamente.
2. Coletar logs de AD DS, DNS e DFS Replication.
3. Tentar despromoção suportada pelo Server Manager/PowerShell.
4. Somente realizar limpeza de metadados após confirmar que o novo DC não voltará.

## Restrições

- Não restaurar snapshot de DC como rollback rotineiro.
- Não iniciar novamente um DC declarado permanentemente removido.
- Não mover FSMO durante uma ocorrência sem diagnóstico.

