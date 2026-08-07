[CmdletBinding()]
param(
    [string]$Destination = '10.100.10.11',
    [int[]]$Ports = @(53, 88, 135, 389, 445)
)

$Ports | ForEach-Object {
    Test-NetConnection $Destination -Port $_ |
        Select-Object ComputerName, SourceAddress, RemotePort, TcpTestSucceeded
}

