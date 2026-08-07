[CmdletBinding()]
param(
    [string]$OutputRoot = "$env:USERPROFILE\Desktop",
    [int]$Hours = 24
)

$ErrorActionPreference = 'Continue'
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$OutputDirectory = Join-Path $OutputRoot "DC-Promotion-Incident-$Timestamp"
New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null

function Save-CommandOutput {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [scriptblock]$Command
    )

    $Path = Join-Path $OutputDirectory "$Name.txt"
    try {
        & $Command 2>&1 | Out-File -FilePath $Path -Encoding utf8 -Width 4096
    }
    catch {
        $_ | Format-List * -Force | Out-File -FilePath $Path -Encoding utf8 -Width 4096
    }
}

Save-CommandOutput -Name 'Computer' -Command {
    Get-CimInstance Win32_ComputerSystem |
        Select-Object Name,Domain,PartOfDomain,Model
    Get-CimInstance Win32_OperatingSystem |
        Select-Object Caption,Version,LastBootUpTime,FreePhysicalMemory
}

Save-CommandOutput -Name 'DomainControllers' -Command {
    Import-Module ActiveDirectory
    Get-ADDomainController -Filter * |
        Select-Object HostName,IPv4Address,Site,IsGlobalCatalog,OperationMasterRoles
}

Save-CommandOutput -Name 'FSMO' -Command { netdom query fsmo }
Save-CommandOutput -Name 'Repadmin-Summary' -Command { repadmin /replsummary }
Save-CommandOutput -Name 'Repadmin-ShowRepl' -Command { repadmin /showrepl }
Save-CommandOutput -Name 'DCDiag-Core' -Command {
    dcdiag /test:Advertising /test:DNS /test:SysVolCheck /test:NetLogons /test:Replications /v
}

$Logs = @('System','Application','Directory Service','DNS Server','DFS Replication')
foreach ($Log in $Logs) {
    $SafeName = $Log -replace '[^A-Za-z0-9-]','-'
    Save-CommandOutput -Name "Events-$SafeName" -Command {
        Get-WinEvent -FilterHashtable @{
            LogName = $Log
            StartTime = (Get-Date).AddHours(-$Hours)
            Level = 1,2,3
        } -ErrorAction Stop |
        Select-Object TimeCreated,Id,LevelDisplayName,ProviderName,Message |
        Format-List
    }
}

Save-CommandOutput -Name 'DNS' -Command {
    Get-DnsClientServerAddress -AddressFamily IPv4
    Resolve-DnsName _ldap._tcp.dc._msdcs.wcrpc.lan -Type SRV
}

Save-CommandOutput -Name 'Time' -Command {
    w32tm /query /source
    w32tm /query /status
}

$Archive = "$OutputDirectory.zip"
Compress-Archive -Path "$OutputDirectory\*" -DestinationPath $Archive -Force

Write-Host "Coleta concluída: $Archive" -ForegroundColor Green

