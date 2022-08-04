function Get-SystemHardware {
    $systemHardware = Get-CIMInstance win32_computersystem
    
    Write-Output "System Hardware:"
    new-object -typename psobject -property @{Description=$systemHardware.Description} | Format-List -Property Description
}

function Get-OperatingSystem {
    $systemOS = Get-CimInstance win32_operatingsystem
    
    Write-Output "Operating System:"
    New-Object -typename psobject -property @{Name=$systemOS.Caption
                                                     Version=$systemOS.Version.ToString()} | Format-List -Property Name,Version
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

    Write-Output "System Processor:"
    New-Object -TypeName psObject -Property @{Description=$systemProcessor.Description[0]
                                                     NumberOfCores=$coreSum
                                                     "MaxClockSpeed(Ghz)"=$processorSpeed
                                                     L1CacheSize=$processorL1CacheSize
                                                     L2CacheSize=$processorL2CacheSize
                                                     L3CacheSize=$processorL3CacheSize} | Format-List -Property Description,NumberOfCores,"MaxClockSpeed(Ghz)",L1CacheSize,L2CacheSize,L3CacheSize
}

function Get-SystemRAM {
    $systemRAM = Get-CimInstance win32_physicalmemory

    Write-Output "System RAM:"
    New-Object -TypeName psObject -Property @{Vendor=$systemRAM.Manufacturer
                                                    Description=$systemRAM.Description
                                                    Bank=$systemRAM.BankLabel
                                                    "Capacity(GB)"=$systemRAM.Capacity / 1gb -as [int]
                                                    Slot=$systemRAM.DeviceLocator} | Format-Table -AutoSize -Wrap -Property Vendor,Description,Bank,"Capacity(GB)",Slot
    Write-Output "Total Capacity of RAM(GB):"
    Write-Output ([float]$systemRAM.Capacity / 1gb)

}

function Get-ActiveInterfaces {
    $activeInterfaces = get-ciminstance win32_networkadapterconfiguration | Where-Object ipenabled -eq $true
    #$activeInterfaces | Format-Table -AutoSize -Wrap Description,Index,IPAddress,IPSubnet,DNSDomain,DNSHostName,DNSServerSearchOrder

    Write-Output "Active System Network Interfaces:"
    New-Object -TypeName psObject -Property @{Description=$activeInterfaces.Description
                                                     Index=$activeInterfaces.Index
                                                     IPAddress=$activeInterfaces.IPAddress
                                                     IPSubnet=$activeInterfaces.IPSubnet
                                                     DNSDomain=$activeInterfaces.DNSDomain
                                                     DNSHostName=$activeInterfaces.DNSHostName
                                                     DNSServer=$activeInterfaces.DNSServerSearchOrder} | Format-Table -AutoSize -Wrap Description,Index,IPAddress,IPSubnet,DNSDomain,DNSHostName,DNSServer
}

function Get-SystemVideoCard {
    $systemVideoCard = Get-CimInstance win32_videocontroller

    $videoDescription = $systemVideoCard.Name #Represents vendor and name.
    $videoResolution = $systemVideoCard.CurrentHorizontalResolution.ToString() + "x" + $systemVideoCard.CurrentVerticalResolution.ToString()

    Write-Output "System Video Card:"
    New-Object -TypeName psObject -Property @{Name=$systemVideoCard.Name
                                                     Resolution=$videoResolution} | Format-List -Property Name,Resolution
}

function Get-DiskDrives {

    $diskdrives = Get-CIMInstance CIM_diskdrive
    Write-Output "System Disks:"
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

  Export-ModuleMember -Function 'Get-SystemHardware','Get-OperatingSystem','Get-SystemProcessor','Get-SystemRAM','Get-ActiveInterfaces','Get-SystemVideoCard','Get-DiskDrives'