[CmdletBinding()]
param(
    [string[]]$DomainControllers = @('SRVAD2022', 'SRVAD2025')
)

$ErrorActionPreference = 'Continue'

Write-Host '=== Compartilhamentos ===' -ForegroundColor Cyan
$shareResults = foreach ($dc in $DomainControllers) {
    [PSCustomObject]@{
        DomainController = $dc
        SYSVOL           = Test-Path "\\$dc\SYSVOL"
        NETLOGON         = Test-Path "\\$dc\NETLOGON"
    }
}
$shareResults | Format-Table -AutoSize

Write-Host '=== Estado local do DFSR ===' -ForegroundColor Cyan
Get-CimInstance -Namespace root\MicrosoftDFS -ClassName DfsrReplicatedFolderInfo |
    Where-Object ReplicatedFolderName -eq 'SYSVOL Share' |
    Select-Object ReplicationGroupName, ReplicatedFolderName, State |
    Format-Table -AutoSize

Write-Host '=== Serviço DFSR local ===' -ForegroundColor Cyan
Get-Service DFSR | Select-Object MachineName, Status, StartType | Format-Table -AutoSize

Write-Host '=== SysvolReady local ===' -ForegroundColor Cyan
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' |
    Select-Object SysvolReady |
    Format-List

Write-Host '=== Replicação do Active Directory ===' -ForegroundColor Cyan
repadmin.exe /replsummary
repadmin.exe /showrepl

Write-Host '=== DCDIAG local ===' -ForegroundColor Cyan
$tests = 'Advertising', 'SysVolCheck', 'NetLogons', 'DNS'
foreach ($test in $tests) {
    & dcdiag.exe "/test:$test"
}

Write-Host '=== Eventos DFSR recentes ===' -ForegroundColor Cyan
Get-WinEvent -FilterHashtable @{
    LogName   = 'DFS Replication'
    StartTime = (Get-Date).AddHours(-24)
} -ErrorAction SilentlyContinue |
    Where-Object Id -in 2213, 4012, 4114, 4602, 4604, 4612, 4614, 5002, 5008, 5014 |
    Select-Object TimeCreated, Id, LevelDisplayName, Message |
    Sort-Object TimeCreated |
    Format-List

