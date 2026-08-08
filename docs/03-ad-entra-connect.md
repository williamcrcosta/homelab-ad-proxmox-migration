# Active Directory e Entra Connect

## Estado do domínio

- Domínio: `wcrpc.lan`.
- Site: `Default-First-Site-Name`.
- DC original: `SRVAD2022` (`10.100.10.11`), DNS, GC, Entra Connect e atual detentor dos cinco FSMO.
- DC adicional: `SRVAD2025` (`10.100.20.10`), DNS e GC, com AD/SYSVOL saudáveis.
- DC antigo: `SRVAD2019`, removido definitivamente.

## Limpeza realizada

- Backup do objeto de computador do `SRVAD2019` antes da remoção.
- Remoção de metadados remanescentes do DC antigo.
- Remoção dos registros DNS NS/SRV que apontavam para o servidor antigo.
- Estado DFSR confirmado como `Eliminated` e consistente.
- `dcdiag` de DNS, SYSVOL, Netlogons e referências empresariais aprovado.

## Entra Connect

- Falha inicial: importação Delta com eventos ADSync 6803 e Directory Synchronization 109.
- DNS do servidor ajustado para usar o DNS do domínio.
- Conectividade HTTPS com endpoints Microsoft validada.
- Microsoft Entra Connect atualizado.
- Scheduler ativo, staging desativado e execuções concluídas com sucesso.
- Connect Health voltou a registrar o servidor como saudável após correção do agente.

## Restrição atual

O Entra Connect permanece no `SRVAD2022`. Sua migração será tratada em mudança separada depois da transferência e estabilização dos FSMO. Não combinar migração do Entra Connect, transferência FSMO e despromoção do DC antigo na mesma janela.
