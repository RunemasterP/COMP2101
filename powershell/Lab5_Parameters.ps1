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

function Get-SystemHardware {
    $systemHardware = Get-CIMInstance win32_computersystem
    
    return new-object -typename psobject -property @{Description=$systemHardware.Description}
}

function Get-OperatingSystem {
    $systemOS = Get-CimInstance win32_operatingsystem
    
    return New-Object -typename psobject -property @{Name=$systemOS.Caption
                                                     Version=$systemOS.Version.ToString()}
}

function Get-SystemProcessor {
    $systemProcessor = Get-CimInstance win32_processor
    $processorSpeed = $systemProcessor.MaxClockSpeed[0] / 1000 
    $coreSum = 0
    foreach ($core in $systemProcessor.NumberOfCores) {
        $coreSum += $core
    }

    if($systemProcessor.L1CacheSize[0] -eq $null) {
        $processorL1CacheSize = "Data Unavailable."
    }
    else {
        $processorL1CacheSize = $systemProcessor.L1CacheSize[0]
    }

    if($systemProcessor.L2CacheSize[0] -eq $null) {
        $processorL2CacheSize = "Data Unavailable."
    }
    else {
        $processorL2CacheSize = $systemProcessor.L2CacheSize[0]
    }

        if($systemProcessor.L3CacheSize[0] -eq $null) {
        $processorL3CacheSize = "Data Unavailable."
    }
    else {
        $processorL3CacheSize = $systemProcessor.L3CacheSize[0]
    }

    
    #return $processorDescription,$processorCoreCount,$processorL1CacheSize,$processorL2CacheSize,$processorL3CacheSize
    return New-Object -TypeName psObject -Property @{Description=$systemProcessor.Description[0]
                                                     NumberOfCores=$coreSum
                                                     "MaxClockSpeed(Ghz)"=$processorSpeed
                                                     L1CacheSize=$processorL1CacheSize
                                                     L2CacheSize=$processorL2CacheSize
                                                     L3CacheSize=$processorL3CacheSize}
}

function Get-SystemRAM {
    $systemRAM = Get-CimInstance win32_physicalmemory

    return New-Object -TypeName psObject -Property @{Vendor=$systemRAM.Manufacturer
                                                    Description=$systemRAM.Description
                                                    Bank=$systemRAM.BankLabel
                                                    "Capacity(GB)"=$systemRAM.Capacity / 1gb -as [int]
                                                    Slot=$systemRAM.DeviceLocator}
}

function Get-ActiveInterfaces {
    $activeInterfaces = get-ciminstance win32_networkadapterconfiguration | Where-Object ipenabled -eq $true
    #$activeInterfaces | Format-Table -AutoSize -Wrap Description,Index,IPAddress,IPSubnet,DNSDomain,DNSHostName,DNSServerSearchOrder

    return New-Object -TypeName psObject -Property @{Description=$activeInterfaces.Description
                                                     Index=$activeInterfaces.Index
                                                     IPAddress=$activeInterfaces.IPAddress
                                                     IPSubnet=$activeInterfaces.IPSubnet
                                                     DNSDomain=$activeInterfaces.DNSDomain
                                                     DNSHostName=$activeInterfaces.DNSHostName
                                                     DNSServer=$activeInterfaces.DNSServerSearchOrder}
}

function Get-SystemVideoCard {
    $systemVideoCard = Get-CimInstance win32_videocontroller

    $videoDescription = $systemVideoCard.Name #Represents vendor and name.
    $videoResolution = $systemVideoCard.CurrentHorizontalResolution.ToString() + "x" + $systemVideoCard.CurrentVerticalResolution.ToString()

    return New-Object -TypeName psObject -Property @{Name=$systemVideoCard.Name
                                                     Resolution=$videoResolution}
}

function Get-DiskDrives {

    $diskdrives = Get-CIMInstance CIM_diskdrive

      foreach ($disk in $diskdrives) {
          $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
          foreach ($partition in $partitions) {
                $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
                foreach ($logicaldisk in $logicaldisks) {
                         new-object -typename psobject -property @{Manufacturer=$disk.Manufacturer
                                                                   Location=$partition.deviceid
                                                                   Drive=$logicaldisk.deviceid
                                                                   "Size(GB)"=$logicaldisk.size / 1gb -as [int]
                                                                   }
               }
          }
      }

  }

if(!$System -and !$Network -and !$Disks) {
    Write-Output "Nothing to report here boss!"
}

if($System) {
    Write-Output "System Hardware:"
    Get-SystemHardware | Format-List -Property Description

    Write-Output "Operating System:"
    Get-OperatingSystem | Format-List -Property Name,Version

    Write-Output "System Processor:"
    Get-SystemProcessor | Format-List -Property Description,NumberOfCores,"MaxClockSpeed(Ghz)",L1CacheSize,L2CacheSize,L3CacheSize

    Write-Output "System RAM:"
    Get-SystemRAM | Format-Table -AutoSize -Wrap -Property Vendor,Description,Bank,"Capacity(GB)",Slot
    Write-Output "Total Capacity of RAM(GB):"
    Get-SystemRAM | Select -ExpandProperty "Capacity(GB)"
    Write-Output "`n"

    Write-Output "System Video Card:"
    Get-SystemVideoCard | Format-List -Property Name,Resolution
}

if($Network) {
    Write-Output "Active System Network Interfaces:"
    Get-ActiveInterfaces | Format-Table -AutoSize -Wrap Description,Index,IPAddress,IPSubnet,DNSDomain,DNSHostName,DNSServer
}

if($Disks) {
    Write-Output "System Disks:"
    Get-DiskDrives
}