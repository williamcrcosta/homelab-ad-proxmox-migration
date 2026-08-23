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

## Antes da transferência FSMO

Foram criadas três camadas de recuperação para o `SRVAD2025`:

1. backup snapshot consistente da VM no Proxmox;
2. backup cold completo da VM;
3. backup System State pelo Windows Server Backup.

Em caso de falha após uma transferência normal, priorizar diagnóstico e transferência suportada de volta ao `SRVAD2022`, se ele continuar íntegro. Não restaurar simultaneamente dois controladores a estados antigos. Restauração de DC e System State deve seguir procedimento específico de recuperação do Active Directory.

O backup operacional mais recente da VM 750 está sob o storage `backup-750-srvad2025`. Os System States ficam em subdiretórios datados dentro de `750-srvad2025`. Antes de restaurar, confirmar a integridade do arquivo, isolar a VM restaurada e definir se a recuperação do AD será autoritativa ou não autoritativa.
