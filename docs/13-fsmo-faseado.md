# Plano de transferência FSMO faseada

## Estado inicial

As cinco funções permanecem no `SRVAD2022`:

- Schema Master;
- Domain Naming Master;
- PDC Emulator;
- RID Master;
- Infrastructure Master.

O `SRVAD2025` está saudável, mas nenhuma transferência foi iniciada.

## Estratégia

Executar uma função por etapa, com validação e janela de observação entre elas. O PDC Emulator será transferido por último por concentrar horário do domínio, alterações de senha, bloqueios e descoberta preferencial.

| Fase | Função | Observação |
|---:|---|---|
| 1 | Schema Master | Validar floresta e replicação |
| 2 | Domain Naming Master | Reunir as duas funções de floresta no novo DC |
| 3 | Infrastructure Master | Validar domínio |
| 4 | RID Master | Validar alocação RID e replicação |
| 5 | PDC Emulator | Ajustar NTP imediatamente e executar auditoria final |

Durante o intervalo entre as fases 1 e 2, o BPA pode avisar temporariamente que Schema Master e Domain Naming Master estão separados. Durante o intervalo entre RID e PDC, pode ocorrer aviso equivalente. Esses intervalos devem ser curtos, controlados e documentados.

## Gate obrigatório de cada fase

Antes e depois de cada transferência:

```powershell
netdom query fsmo
repadmin /replsummary
dcdiag /test:Advertising /s:SRVAD2025
dcdiag /test:DNS /s:SRVAD2025
```

Critérios:

- zero falhas de replicação;
- DNS aprovado;
- Advertising aprovado;
- SYSVOL e NETLOGON presentes;
- eventos críticos novos analisados;
- detentor da função confirmado.

## Exemplo da Fase 1

```powershell
Import-Module ActiveDirectory

Move-ADDirectoryServerOperationMasterRole `
  -Identity "SRVAD2025" `
  -OperationMasterRole SchemaMaster `
  -Confirm
```

Esta operação deve ser uma transferência normal. Não utilizar `-Force` nem realizar seize enquanto o `SRVAD2022` estiver operacional.

## Condições de parada

Interromper a sequência se ocorrer:

- erro de DNS, Advertising, SYSVOL ou Netlogon;
- falha de replicação;
- evento crítico de AD DS, DNS, DFSR ou Kerberos;
- instabilidade de boot ou indisponibilidade do túnel IPsec;
- resultado FSMO diferente do esperado.

## Fase final — PDC Emulator

Após transferir o PDC:

1. configurar o `SRVAD2025` como fonte confiável de horário do domínio;
2. garantir que o `SRVAD2022` volte a seguir a hierarquia do domínio;
3. validar `w32tm`, Kerberos, DNS, replicação e Entra Connect;
4. manter os dois DCs ligados durante a estabilização;
5. não despromover o `SRVAD2022` na mesma janela.
