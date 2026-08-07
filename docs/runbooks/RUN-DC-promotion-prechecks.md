# Runbook — Pré-validação para promover DC adicional

## Objetivo

Reduzir o risco antes de promover um Windows Server como controlador adicional.

## Gate 1 — Backup do DC existente

```powershell
Get-WindowsFeature Windows-Server-Backup
wbadmin get versions
wbadmin get items -version:<IDENTIFICADOR>
```

Critério: backup recente, acessível e contendo `System State`, `AD/NTDS`, `SYSVOL` e `Registry`.

## Gate 2 — Saúde do domínio existente

```powershell
dcdiag /test:Advertising
dcdiag /test:DNS
dcdiag /test:SysVolCheck
dcdiag /test:NetLogons
dcdiag /test:Replications
netdom query fsmo
repadmin /replsummary
```

Documentar falsos positivos conhecidos separadamente. Não promover com erros atuais de DNS, SYSVOL, NETLOGON ou replicação.

## Gate 3 — Identidade, DNS e horário do membro

```powershell
Get-CimInstance Win32_ComputerSystem |
  Select-Object Name,Domain,PartOfDomain

Test-ComputerSecureChannel -Verbose
nltest /dsgetdc:wcrpc.lan
Get-DnsClientServerAddress -AddressFamily IPv4
Resolve-DnsName _ldap._tcp.dc._msdcs.wcrpc.lan -Type SRV
w32tm /query /source
w32tm /query /status
```

Critério: domínio correto, canal seguro válido, DNS apontando somente para DNS do AD e horário sincronizado.

## Gate 4 — Rede

Validar portas conforme a arquitetura. Em redes separadas, considerar também RPC dinâmico e protocolos UDP necessários ao AD.

```powershell
$Ports = 53,88,135,389,445,464,636,3268,3269,9389
$Results = foreach ($Port in $Ports) {
    [PSCustomObject]@{
        Port = $Port
        Success = Test-NetConnection 10.100.10.11 -Port $Port -InformationLevel Quiet
    }
}
$Results | Format-Table -AutoSize
```

## Gate 5 — Hypervisor e boot

- Confirmar UEFI/OVMF e ordem de boot.
- Registrar configuração da VM antes da promoção.
- Confirmar driver de armazenamento e NIC VirtIO.
- Confirmar estado do Secure Boot e chaves inscritas.
- Executar pelo menos um reboot normal imediatamente antes da promoção.
- Confirmar que a VM volta a iniciar sem ISO e sem intervenção.

Este gate deve ser obrigatório em uma nova tentativa, pois separa problema de promoção de problema latente de boot.

## Gate 6 — Aplicações dependentes

Se o DC existente também executar Microsoft Entra Connect:

```powershell
Get-Service ADSync,AzureADConnectHealthAgent
Get-ADSyncScheduler
Get-ADSyncConnectorRunStatus
Get-ADSyncRunProfileResult |
  Sort-Object StartDate -Descending |
  Select-Object -First 10
```

Critério: serviço em execução, scheduler habilitado, staging conforme desenho e últimas operações em `success`.

## Gate 7 — Teste oficial

Executar `Test-ADDSDomainControllerInstallation` e arquivar a saída. Aviso de delegação DNS pode ser esperado em um namespace interno sem zona-pai autoritativa.

## Aprovação

Somente avançar quando todos os gates estiverem registrados como `PASS`, `ACCEPTED WARNING` ou `NOT APPLICABLE`, com justificativa.

