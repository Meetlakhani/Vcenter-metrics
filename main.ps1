Get-Module -Name VMware.PowerCLI -ListAvailable
Import-Module VMware.PowerCLI 
Connect-VIServer -Server "Ip address of the server" -User "Your username" -Password "Your password"

$interval = 60
$cluster = Get-Cluster -Name "Your Cluster name"


while($true) {

if ($cluster) {
    $vms = Get-Cluster $cluster | Get-VM
    $vmDetails = @()

    foreach ($vm in $vms) {
        $vmView = Get-View -Id $vm.Id
        $description = if ($vmView.Config.Annotation) { $vmView.Config.Annotation } else { "No Description" }
        $uptime = if ($vmView.Runtime.PowerState -eq 'poweredOn' -and $vmView.Runtime.BootTime) { 
            (Get-Date) - $vmView.Runtime.BootTime | Select-Object -ExpandProperty TotalSeconds 
        } else { 
            0 
        }
        $macAddresses = ($vmView.Config.Hardware.Device | Where-Object { $_.DeviceInfo.Label -match "Network adapter" } | ForEach-Object { $_.MacAddress }) -join ", "
        

        $vmDetail = [PSCustomObject]@{
            VMName = $vm.Name
            PowerState = $vmView.Runtime.PowerState
            NumCpu = $vmView.Config.Hardware.NumCPU
            NumCoresPerSocket = $vmView.Config.Hardware.NumCoresPerSocket
            MemoryMB = $vmView.Config.Hardware.MemoryMB
            GuestOS = $vmView.Summary.Config.GuestFullName
            ProvisionedSpaceGB = [Math]::Round(($vmView.Summary.Storage.Committed + $vmView.Summary.Storage.Uncommitted) / 1GB, 2)
            UsedSpaceGB = [Math]::Round($vmView.Summary.Storage.Committed / 1GB, 2)
            Datastore = ($vmView.Datastore | ForEach-Object { (Get-View $_).Name }) -join ", "
            Folder = (Get-View $vmView.Parent).Name
            ResourcePool = (Get-View $vmView.ResourcePool).Name
            NetworkName = ($vmView.Network | ForEach-Object { (Get-View $_).Name }) -join ", "
            MacAddresses = $macAddresses
            GuestId = $vmView.Config.GuestId
            Uuid = $vmView.Config.Uuid
            InstanceUuid = $vmView.Config.InstanceUuid
            Description = $description
            ToolsStatus = $vmView.Guest.ToolsStatus
            ToolsVersion = $vmView.Guest.ToolsVersion
            ToolsRunningStatus = $vmView.Guest.ToolsRunningStatus
            CpuUsageMHz = $vmView.Summary.QuickStats.OverallCpuUsage
            MemoryUsageMB = $vmView.Summary.QuickStats.GuestMemoryUsage
            MaxCpuUsageMHz = $vmView.Runtime.MaxCpuUsage
            MaxMemoryUsageMB = $vmView.Runtime.MaxMemoryUsage
            IpAddress = $vmView.Guest.IpAddress
            DnsName = $vmView.Guest.HostName
            LastBootTime = $vmView.Runtime.BootTime
            UptimeSeconds = $uptime
            HardwareVersion = $vmView.Config.Version
            VMwareTools = $vmView.Config.Tools.ToolsVersion
            CpuHotAddEnabled = $vmView.Config.CpuHotAddEnabled
            MemoryHotAddEnabled = $vmView.Config.MemoryHotAddEnabled
            ChangeVersion = $vmView.Config.ChangeVersion
            NumVirtualDisks = $vmView.Config.Hardware.Device.Where({$_ -is [VMware.Vim.VirtualDisk]}).Count
            NumSnapshots = $vmView.Snapshot.RootSnapshotList.Count
            VMHostName = (Get-View $vmView.Runtime.Host).Name
            Cluster = $cluster.Name
            vApp = if ($vmView.ParentVApp) { (Get-View $vmView.ParentVApp).Name } else { "N/A" }
            LatencySensitivity = $vmView.Config.LatencySensitivity.Level
            GuestHeartbeatStatus = $VMView.GuestHeartbeatStatus
            OverallStatus = $VMView.OverallStatus

        }
        $vmDetails += $vmDetail
    }

    "VM Details:"
    $vmDetails
    Write-Output "=================================================================="




$hosts = Get-Cluster $cluster | Get-VMHost

# Initialize an array to store host details
$hostDetails = @()

# Define the GHz constant
$GHz = 1e9

# Retrieve details for each host
foreach ($ehost in $hosts) {
    
    $hostView = Get-View -Id $ehost.Id
    $cpuFrequencyGHz = if ($hostView.Hardware.CpuInfo.Hz) { $hostView.Hardware.CpuInfo.Hz / $GHz } else { 0 }
    $cpuDescription = "$($hostView.Hardware.CpuInfo.NumCpuPackages) x $($hostView.Hardware.CpuInfo.NumCpuCores / $hostView.Hardware.CpuInfo.NumCpuPackages) cores @ $cpuFrequencyGHz GHz"
    $uptime = if ($hostView.Runtime.PowerState -eq 'poweredOn' -and $hostView.Runtime.BootTime) { 
        (Get-Date) - $hostView.Runtime.BootTime | Select-Object -ExpandProperty TotalSeconds 
    } else { 
        0 
    }
    $vsanConfig = Get-VsanClusterConfiguration -Cluster $cluster

    $hostDetail = [PSCustomObject]@{
        HostName = $ehost.Name
        ConnectionState = $ehost.ConnectionState
        PowerState = $ehost.PowerState
        Version = $eHost.Version
        Build = $eHost.Build
        Cluster = $eHost.Parent
        TotalCpu = $cpuDescription
        NumCpu = $eHost.NumCpu
        CpuTotalMhz = $eHost.CpuTotalMhz
        CpuUsageMhz = $eHost.CpuUsageMhz
        MemoryTotalGB = [math]::Round($eHost.MemoryTotalGB, 2)
        MemoryUsageGB = [math]::Round($eHost.MemoryUsageGB, 2)
        HyperthreadingActive = $eHost.HyperthreadingActive
        TimeZone = $eHost.TimeZone
        Model = $hostView.Hardware.SystemInfo.Model
        Manufacturer = $hostView.Hardware.SystemInfo.Vendor
        UptimeSeconds = $uptime
        TotalVms = (Get-VMHost $ehost).ExtensionData.Vm.Count
        Vms = (Get-VMHost $ehost | Get-VM).Name -join ", "
        Datastores = ($hostView.Datastore | % { (Get-View $_).Name }) -join ", "
        Networks = ($hostView.Network | % { (Get-View $_).Name }) -join ", "
        ProcessorType = $eHost.ProcessorType
        NumberOfNics = $hostView.Config.Network.Pnic.Count
        NumberOfHBAs = $hostView.Config.StorageDevice.HostBusAdapter.Count
        MaintenanceMode = $hostView.Runtime.InMaintenanceMode
        IsVsanEnabled = $vsanConfig.VsanEnabled
        IsSSHEnabled = (Get-VMHostFirewallException -VMHost $eHost | Where-Object {$_.Name -eq "SSH Server"}).Enabled
        LastBootTime = $hostView.Runtime.BootTime
        VMKernelAdapters = ($eHost | Get-VMHostNetworkAdapter -VMKernel | Select-Object -ExpandProperty Name) -join ', '
        VirtualSwitches = ($eHost | Get-VirtualSwitch | Select-Object -ExpandProperty Name) -join ', '
        PhysicalNICs = ($eHost | Get-VMHostNetworkAdapter -Physical | Select-Object -ExpandProperty Name) -join ', '
        NTPServers = ($eHost | Get-VMHostNtpServer) -join ', '
        PatchLevel = $eHost.ExtensionData.Config.Product.PatchLevel
        HostConfigStatus = $hostView.ConfigStatus
        OverallStatus = $hostView.OverallStatus
    }

    $hostDetails += $hostDetail
}


# Display host details in a table format
"Host Details:"
$hostDetails



"==============================================================================="


$currentStartTime = (Get-Date).AddSeconds(-60)  # Assuming a 60-second interval
$currentEndTime = Get-Date

$stats = Get-VsanStat -Entity $cluster -StartTime $currentStartTime -EndTime $currentEndTime

if ($stats.Count -gt 0) {
    $vsanDetails = [PSCustomObject]@{
        Timestamp = $stats[0].Time
        Cluster = $stats[0].Entity
    }

    foreach ($stat in $stats) {
        $vsanDetails | Add-Member -NotePropertyName $stat.Name -NotePropertyValue "$($stat.Value) $($stat.Unit)"
    }

    # Custom format for $vsanDetails
    $vsanDetails | Add-Member -MemberType ScriptMethod -Name ToString -Value {
        $output = "Timestamp = $($this.Timestamp)`nCluster = $($this.Cluster)`n"
        $this.PSObject.Properties | Where-Object { $_.Name -ne "Timestamp" -and $_.Name -ne "Cluster" } | ForEach-Object {
            $output += "`n$($_.Name) = $($_.Value)"
        }
        return $output
    } -Force
}
else {
    $vsanDetails = "No vSAN stats found for the given time range."
}

# Now you can simply use $vsanDetails to get the formatted output
"Vsan Details"
$vsanDetails

"==============================================================================="



$currentStartTime = (Get-Date).AddMinutes(-5760)
$currentEndTime = Get-Date

$stats = Get-Stat -Entity $cluster -Start $currentStartTime -Finish $currentEndTime

if ($stats.Count -gt 0) {
    $perfDetails = [PSCustomObject]@{
        Timestamp = $stats[0].Timestamp
        Cluster = $stats[0].Entity
    }

    # foreach ($stat in $stats) {
    #     $perfDetails | Add-Member -NotePropertyName $stat.MetricId -NotePropertyValue $stat.Value -NotePropertyUnit $stat.Unit
    # }

    
    foreach ($stat in $stats) {
        $perfDetails | Add-Member -NotePropertyName $stat.MetricId -NotePropertyValue "$($stat.Value) $($stat.Unit)"
    }

    # Custom format for $vsanDetails
    $perfDetails | Add-Member -MemberType ScriptMethod -Name ToString -Value {
        $output = "Timestamp = $($this.Timestamp)`nCluster = $($this.Cluster)`n"
        $this.PSObject.Properties | Where-Object { $_.Name -ne "Timestamp" -and $_.Name -ne "Cluster" } | ForEach-Object {
            $output += "`n$($_.Name) = $($_.Value)"
        }
        return $output
    } -Force
}
else {
    $perfDetails = "No Performance stats found for the given time range."
}

"Performance Details"
$perfDetails



}

Start-Sleep -Seconds $interval

}
