# Below are some of the commands to fetch metrics which might be useful.


1) Identify the vSan cluster

- $cluster = Get-Cluster -Name "Your cluster name”

2) Retrieve all available metrics for the cluster

- Get-VsanStat -Entity $cluster -Name *

3) To get specific metrics like “Read Throughput” for VM consumption:

- Get-VsanStat -Entity $cluster -Name VMConsumption.ReadThroughput

4) Use wildcards to explore available metrics:

- Get-VsanStat -Entity $cluster -Name VMConsumption*

5) Get-VsanClusterConfiguration -Cluster $cluster

6) Test-VsanClusterHealth -Cluster $cluster

7) Test-VsanNetworkPerformance -Cluster $cluster

8) Test-VsanVMCreation -Cluster $cluster

9) Get-VsanSpaceUsage -Cluster $cluster

10) Get-VsanRuntimeInfo -Cluster $cluster

11) Get-VsanObject -Cluster $cluster

12) Get-VsanClusterPowerState -Cluster $cluster

13)  Get-Stat -Entity $cluster -Stat "cpu.usage.average" -Realtime

14) Get-Stat -Entity $cluster -Stat "mem.usage.average" -Realtime

15) Get-Stat -Entity $cluster -Stat "cpu.usagemhz.average" -Realtime

16) Get-vSphereServerConfiguration

17) Invoke-GetNetworking

18) Invoke-GetHealthSettings

19) Get-VMHost

20) Get-Cluster 

21) Get-DataStore -Name "vsanDatastore”

22) Get-VM -Name "oasis-ux-01” (Note: Replace the name with VM name you want)

23) Get-VsanStat -Entity $cluster -Name “Backend.ReadIops”

24) Get-VsanStat -Entity $cluster -Name “Backend.ReadThroughput”

25) Get-VsanStat -Entity $cluster -Name “Backend.WriteIops”

26) Get-VsanStat -Entity $cluster -Name “Backend.OutstandingIO”

27) Get-VsanStat -Entity $cluster -Name “VMConsumption.ReadIops”

28) Get-VsanStat -Entity $cluster -Name “VMConsumption.WriteIops”

29) Get-VsanStat -Entity $cluster -Name “VMConsumption.Congestion”

30) Get-VsanStat -Entity $cluster -Name “Capacity.TotalCapacity”

31) Get-VsanStat -Entity $cluster -Name “Capacity.UsedCapacity”

32) Get-VsanStat -Entity $cluster -Name “ Capacity.FreeCapacity”

33) Get-VsanStat -Entity $cluster -Name “Capacity.DedupRatio”

34) Get-VsanDiskGroup

35) Get-HardDisk -Datastore "VsanDatastore”

36) Invoke-GetHealthDatabaseStorage

37) Get-VsanStat -Entity $cluster 

38) Get-Stat -Entity $cluster -Cpu -IntervalSecs 60

39) Get-Stat -Entity $cluster -Memory -IntervalSecs 60
