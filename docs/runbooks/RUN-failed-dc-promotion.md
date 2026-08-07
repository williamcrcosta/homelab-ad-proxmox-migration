# Runbook — DC promovido que não inicia

## Objetivo

Orientar a resposta quando o DCPromo termina, mas o servidor não inicia após o reboot.

## Regra principal

Não tratar a VM como um member server comum. Se o DCPromo retornou sucesso, a identidade de DC pode já existir no Active Directory.

## Fase 1 — Preservar

- Manter o DC saudável em operação.
- Não restaurar snapshot do novo DC sem plano de recuperação do AD.
- Não executar uma segunda promoção.
- Não apagar objeto de computador, NTDS Settings ou registros DNS isoladamente.
- Preservar disco e configuração da VM para análise.

## Fase 2 — Determinar o estágio atingido

No DC saudável:

```powershell
Get-ADDomainController -Filter * |
  Select-Object HostName,IPv4Address,Site,IsGlobalCatalog

netdom query fsmo
repadmin /replsummary
repadmin /showrepl
```

No ambiente de recuperação do DC com falha:

```cmd
bcdedit /enum {default}
chkdsk C:
dir C:\Windows\Minidump /o-d
dir C:\Windows\MEMORY.DMP
type C:\Windows\debug\dcpromo.log | more
```

## Fase 3 — Escolher estratégia

### Recuperar

Escolher quando houver dados exclusivos, quando a causa estiver identificada ou quando a recuperação for menos arriscada que a limpeza.

Requisitos:

- cópia das evidências;
- alteração única por tentativa;
- registro do resultado e plano de reversão;
- validação completa de AD/DNS/SYSVOL após o boot.

### Reconstruir

Escolher quando o DC for recém-promovido, não possuir FSMO nem dados exclusivos e houver um DC saudável com backup.

Antes de limpar:

- declarar a VM antiga permanentemente fora de uso;
- confirmar todos os FSMO no DC saudável;
- confirmar backup de System State;
- garantir que a VM antiga não voltará à rede;
- aprovar formalmente a limpeza de metadados.

As instruções destrutivas de metadata cleanup devem ser executadas somente após a decisão registrada no ADR e uma segunda conferência dos alvos.

## Fase 4 — Validação pós-recuperação ou reconstrução

```powershell
dcdiag /e /v
dcdiag /test:DNS
dcdiag /test:SysVolCheck
dcdiag /test:NetLogons
repadmin /replsummary
repadmin /showrepl * /csv
Get-ADDomainController -Filter *
```

Também validar compartilhamentos `SYSVOL` e `NETLOGON`, registros SRV, horário e conectividade entre as duas redes.

