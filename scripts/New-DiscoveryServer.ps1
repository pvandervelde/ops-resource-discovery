<#
    .SYNOPSIS

    Connects to the remote machine, pushes all the necessary files up to it, executes the Chef cookbook that installs
    all the required files and applications in order to turn the remote machine into a service discovery server.


    .DESCRIPTION

    The New-DiscoveryServer script takes all the actions necessary configure the remote machine as a service discovery server.


    .PARAMETER computerName

    The name of the machine that should be set up.


    .PARAMETER environmentName

    The name of the environment to which the remote machine should be added.


    .PARAMETER consulLocalAddress

    The URL to the local consul agent.


    .EXAMPLE

    New-WindowsResource -computerName "MyCoolServer"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $computerName         = $(throw 'Please specify the name of the machine that should be configured.'),

    [Parameter(Mandatory = $false)]
    [string] $environmentName      = 'Development',

    [Parameter(Mandatory = $false)]
    [string] $consulLocalAddress   = "http://localhost:8500"
)

Write-Verbose "New-DiscoveryServer - computerName: $computerName"
Write-Verbose "New-DiscoveryServer - environmentName: $environmentName"
Write-Verbose "New-DiscoveryServer - consulLocalAddress: $consulLocalAddress"

# Stop everything if there are errors
$ErrorActionPreference = 'Stop'

$commonParameterSwitches =
    @{
        Verbose = $PSBoundParameters.ContainsKey('Verbose');
        Debug = $PSBoundParameters.ContainsKey('Debug');
        ErrorAction = "Stop"
    }

try
{
    $installationScript = Join-Path $PSScriptRoot 'Initialize-LocalNetworkResource.ps1'
    & $installationScript `
        -computerName $computerName `
        -consulLocalAddress $consulLocalAddress `
        -environmentName $environmentName `
        @commonParameterSwitches
}
catch
{
    $errorRecord = $Error[0]

    $currentErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    try
    {
        Write-Error $errorRecord.Exception
        Write-Error $errorRecord.ScriptStackTrace
        Write-Error $errorRecord.InvocationInfo.PositionMessage
    }
    finally
    {
        $ErrorActionPreference = $currentErrorActionPreference
    }
}