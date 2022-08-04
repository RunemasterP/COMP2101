<#
.SYNOPSIS
Gets various information related to your computer.
.DESCRIPTION
Fetches system (OS, CPU, RAM, GPU), disk, and network information. If no report type is set, you get a message instead.
.PARAMETER system
Switch parameter that displays system related infomration when called.
.PARAMETER disks
Switch parameter that displays hard-drive disk information when called.
.PARAMETER network
Switch parameter that displays active network interface information when called.
.EXAMPLE
Lab5_Parameters.ps1 -System -Disks -Network

Description
---------------------------------------
Test of the command with all parameters invoked: a full report.
.OUTPUTS
Microsoft.PowerShell.Commands.Internal.Format
#>

#These switch type parameters make it so that we just have to invoke the keyword without passing $true.
param([switch]$System = $false, [switch]$Disks = $false, [switch]$Network = $false)

if(!$System -and !$Network -and !$Disks) {
    Write-Output "Nothing to report here boss!"
}

if($System) {
    Get-SystemHardware

    Get-OperatingSystem 

    Get-SystemProcessor 

    Get-SystemRAM 
    Write-Output "`n"

    Get-SystemVideoCard 
}

if($Network) {
    Get-ActiveInterfaces
}

if($Disks) {
    Get-DiskDrives
}