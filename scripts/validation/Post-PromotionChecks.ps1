[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'

Get-ADDomainController -Filter * |
    Select-Object HostName, IPv4Address, Site, IsGlobalCatalog

dcdiag /test:DNS
dcdiag /test:SysVolCheck
dcdiag /test:NetLogons
repadmin /replsummary
repadmin /showrepl
net share
w32tm /query /source

