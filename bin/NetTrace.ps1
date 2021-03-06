﻿<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Agressive sytem enumeration with netsh

.NOTES
   Required Dependencies: netsh {native}
   Remark: Administrator privilges required on shell
   Remark: Dump will be saved under %TMP%\NetTrace.cab {default}
      
.EXAMPLE
   PS C:\> Get-Help .\NetTrace.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:> .\NetTrace.ps1 -NetTrace Enum

.EXAMPLE
   PS C:> .\NetTrace.ps1 -NetTrace Enum -Storage %TMP%

.OUTPUTS
   Trace configuration:
   -------------------------------------------------------------------
   Status:             Running
   Trace File:         C:\Users\pedro\AppData\Local\Temp\NetTrace.etl
   Append:             Off
   Circular:           On
   Max Size:           4096 MB
   Report:             Off
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$NetTrace="false",
   [string]$Storage="%TMP%"
)


$Address = (## Get Local IpAddress
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.status -ne "Disconnected"
    }
).IPv4Address.IPAddress


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($NetTrace -ieq "Enum"){
[int]$counter = 1

    $SYSTEM_SHELL = (([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    If(-not($SYSTEM_SHELL)){## Check if we are running in an higth context (ADMIN)
        Write-Host "[error] Administrator privileges required on shell!" -ForegroundColor red -BackgroundColor black
        Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @redpill
    }Else{
        ## Start sniffing IPv4 trafic
        Write-Host "Agressive sytem enumeration with netsh!`n" -ForegroundColor Green
        cmd /R netsh trace start capture=yes IPv4.Address=$Address protocol=6 tracefile=$Storage\NetTrace.etl maxsize=4096 overwrite=yes
        Start-Sleep -Seconds 3;cmd /R netsh trace stop
    }
    ## Clean OLD files and exit module
    If(Test-Path -Path "$Storage\NetTrace.etl"){
        Remove-Item -Path "$Storage\NetTrace.etl" -Force
        Remove-Item -Path "$Storage\battery-report.xml" -Force
    }
    Write-Host "";Start-Sleep -Seconds 1 
}