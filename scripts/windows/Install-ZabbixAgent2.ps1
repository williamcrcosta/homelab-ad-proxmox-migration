[CmdletBinding()]
param(
    [string]$ZabbixServerActive = '192.168.50.20:30051',
    [string]$AgentHostname = 'SRVAD2025'
)

$ErrorActionPreference = 'Stop'
$version = '7.0.29'
$url = "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/$version/zabbix_agent2-$version-windows-amd64-openssl.msi"
$msi = Join-Path $env:TEMP "zabbix_agent2-$version.msi"
$log = 'C:\zabbix-agent2-install.log'

Invoke-WebRequest -Uri $url -OutFile $msi

$arguments = @(
    '/i', "`"$msi`"", '/qn', '/norestart', '/l*v', "`"$log`"",
    "HOSTNAME=$AgentHostname",
    "SERVERACTIVE=$ZabbixServerActive",
    'STARTAGENTS=0',
    'SKIP=fw'
)

$process = Start-Process msiexec.exe -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    throw "Falha na instalação. ExitCode=$($process.ExitCode). Consulte $log"
}

Get-Service 'Zabbix Agent 2'

