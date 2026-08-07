[CmdletBinding()]
param(
    [string]$Domain = 'wcrpc.lan',
    [string]$CurrentDC = '10.100.10.11',
    [string]$InterfaceAlias = 'Ethernet'
)

$ErrorActionPreference = 'Continue'
$ports = 53, 88, 135, 389, 445

Write-Host '=== Identidade ===' -ForegroundColor Cyan
Get-CimInstance Win32_ComputerSystem |
    Select-Object Name, Domain, PartOfDomain

Write-Host '=== DNS configurado ===' -ForegroundColor Cyan
Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4

Write-Host '=== Resolução do domínio ===' -ForegroundColor Cyan
Resolve-DnsName $Domain
Resolve-DnsName "_ldap._tcp.dc._msdcs.$Domain" -Type SRV

Write-Host '=== Portas do DC atual ===' -ForegroundColor Cyan
foreach ($port in $ports) {
    Test-NetConnection $CurrentDC -Port $port |
        Select-Object ComputerName, RemotePort, TcpTestSucceeded
}

Write-Host '=== Domínio e horário ===' -ForegroundColor Cyan
Test-ComputerSecureChannel -Verbose
nltest "/dsgetdc:$Domain"
w32tm /query /source
w32tm /stripchart "/computer:$CurrentDC" /samples:3 /dataonly

