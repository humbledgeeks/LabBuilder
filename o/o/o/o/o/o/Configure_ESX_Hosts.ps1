#========================================================================================================================
# 
# AUTHOR: HumbledGeeks  
# DATE  : 06/05/2023
# 
# COMMENT: Script to Automate ESX Host and vCenter Configuration
#     
#
# =======================================================================================================================

#========================================================================================================================
# Specify host variables
#========================================================================================================================

$esxiuser = "root"
$esxipass = "VMware2023!"
$VMHosts = "10.101.18.11"
$NTP1 = "0.pool.ntp.org"
$NTP2 = "1.pool.ntp.org"
$DNS1 = "10.101.16.20"
$DNS2 = "9.9.9.9"
$domainname = "humbledgeeks.com"
$sw0name = "vSwitch0"
$sw1name = "vSwitch1"
$sw2name = "vSwitch2"
$sw3name = "vSwitch3"
$sw0nic0 = "vmnic0"
$sw0nic1 = "vmnic1" 
$sw0nic2 = "vmnic2"
$sw0nic3 = "vmnic3"
$sw0nic4 = "vmnic4"
$sw0nic5 = "vmnic5"
$mgmtpgname = "0016-T-ESXi-Mgmt"
$oobmpgname = "0012-T-OOB-Mgmt"
$oobmpgvlan = "12"
$vcenpgname = "0016-T-vCenter"
$vcenpgvlan = "16"
$nlabpgname = "0018-T-Labs"
$nlabpgvlan = "18"
$corepgname = "0020-T-Core-Servers"
$corepgvlan = "20"
$vmopgname = "0017-T-VMO"
$vmovlan = "17"
$vmoip = "10.101.17.11"
$vmosn = "255.255.255.0"
$nfspgname = "0019-T-NFS"
$nfsvlan  = "19"
$nfsip = "10.101.19.11"
$nfssn = "255.255.255.0"
$nfs1name = "NFS_DS001"
$nfs2name = "NFS_DS002"
$nfstg1ip = "10.106.19.10"
$nfs1path = "/NFS_DS001"
$iscsipg1name = "0014-T-iSCSI-A"
$iscsipg1vlan = "14"
$iscsipg2name = "0015-T-iSCSI-B"
$iscsipg2vlan = "15"
$iscsi1ip = "10.101.14.31"
$iscsi2ip = "10.101.15.31"
$iscsi1sn = "255.255.255.0"
$iscsi2sn = "255.255.255.0"



#====================================================================================================================
# Connect to each host
#====================================================================================================================

write-host Connecting to vCenter Server instance -ForegroundColor Green
Connect-VIServer -Server $VMHosts -User $esxiuser -Password $esxipass

#====================================================================================================================
# Configure NTP Server and Restart Service
#====================================================================================================================

write-host Configure NTP Server and Restarting Service -ForegroundColor Green
#Get-VMHost | Add-VMHostNtpServer -NtpServer us.pool.ntp.org
#Get-VMHost | Add-VMHostNtpServer -NtpServer us.pool.ntp.org
Get-VMHost | Add-VMHostNtpServer -NtpServer $NTP1, $NTP2
Get-VMHost | Get-VMHostService | Where-Object {$_.Key -eq "ntpd"} | Restart-VMHostService -Confirm:$false

#====================================================================================================================
# Configure DNS Server
#====================================================================================================================

write-host Configure DNS Server and Restarting Service -ForegroundColor Green
#Get-VMHost | Get-VMHostNetwork | Set-VMHostNetwork -DnsAddress $DNS1, $DNS2
Get-VMHost | Get-VMHostNetwork | Set-VMHostNetwork -DomainName $domainname -DNSAddress $dns1 , $dns2 -Confirm:$false

#====================================================================================================================
# Rename Local Datastore (if needed)
#====================================================================================================================

#write-host Rename Local Datastore -ForegroundColor Green
#Get-Datastore -Name datastore1 | Set-Datastore -Name $_.localdatastore

#====================================================================================================================
#  Security Hardening Advanced Settings
#====================================================================================================================
write-host Security Hardening Advanced Settings -ForegroundColor Green

#Set-AdvancedSetting -AdvancedSetting UserVars.SuppressShellWarning -Value 1 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Config.HostAgent.log.level | Set-AdvancedSetting -Value info -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Config.HostAgent.plugins.solo.enableMob | Set-AdvancedSetting -Value False -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Mem.ShareForceSalting | Set-AdvancedSetting -Value 2 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Security.AccountLockFailures | Set-AdvancedSetting -Value 5 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Security.AccountUnlockTime | Set-AdvancedSetting -Value 900 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Security.PasswordHistory | Set-AdvancedSetting -Value 5 -Confirm:$false
#Get-VMHost | Get-AdvancedSetting -Name Security.PasswordQulityControl | Set-AdvancedSetting -Value "similar=deny retry=3 min=disabled,disabled,disabled,disabled,15" -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name UserVars.DcuiTimeOut | Set-AdvancedSetting -Value 600 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name UserVars.ESXiShellInteractiveTimeOut | Set-AdvancedSetting -Value 900 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name UserVars.ESXiShellTimeOut | Set-AdvancedSetting -Value 900 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name UserVars.ESXiVPsDisabledProtocols | Set-AdvancedSetting -Value "sslv3,tlsv1,tlsv1.1" -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name UserVars.SuppressShellWarning | Set-AdvancedSetting -Value 1 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name VMkernel.Boot.execInstalledOnly | Set-AdvancedSetting -Value True -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Mem.ShareForceSalting | Set-AdvancedSetting -Value 0 -Confirm:$false
Get-VMHost | Get-AdvancedSetting -Name Misc.BlueScreenTimeout | Set-AdvancedSetting -Value 60 -Confirm:$false


#====================================================================================================================
#  NFS Advanced Settings
#====================================================================================================================
write-host NFS NetApp Best Practices Advanced Settings -ForegroundColor Green

Get-VMHost  | Set-VMHostAdvancedConfiguration -Name Net.TcpipHeapSize -Value 32
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name Net.TcpipHeapMax -Value 512
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name NFS.MaxVolumes -Value 256
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name NFS.HeartbeatMaxFailures -Value 10
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name NFS.HeartbeatFrequency -Value 12
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name NFS.HeartbeatTimeout -Value 5
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name NFS.MaxQueueDepth -Value 64
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name Disk.QFullSampleSize -Value 32
Get-VMHost  | Set-VMHostAdvancedConfiguration -Name Disk.QFullThreshold -Value 8
Get-VMHost  | Get-AdvancedSetting -Name 'Power.CPUPolicy' | Set-AdvancedSetting -Value 'High Performance' -Confirm:$false
Get-VMHost  | Get-AdvancedSetting -Name 'Power.CPUPolicy' | Set-AdvancedSetting -Value 'High Performance' -Confirm:$false

#====================================================================================================================
# Configure local networking
#====================================================================================================================

#====================================================================================================================
# Add Physical Adapter and Edit MTU on vSwitch0 (needed?)
#====================================================================================================================

write-host Add Physical Adapter on vSwitch0 -ForegroundColor Green
	
Get-VirtualSwitch -Name $sw0name | Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic (Get-VMHostNetworkAdapter -Physical -Name $sw0nic1) -Confirm:$false
	
#====================================================================================================================
# Create additional vSwithes / Add Physical Adapters / Set MTU
#====================================================================================================================

#====================================================================================================================
# Edit NIC Teaming Policy
#====================================================================================================================
write-host Add Additional NIC to vSwitch0 and Make both vmnics active -ForegroundColor Green

Get-VirtualSwitch -Name $sw0name | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $sw0nic0,$sw0nic1
#Get-VirtualSwitch -name $sw0name | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $sw0nic0 -MakeNicStandby $sw0nic1
	
#====================================================================================================================
# Remove Default VMPG
#====================================================================================================================
write-host Remove Default Port Group -ForegroundColor Green

Get-VirtualSwitch -name $sw0name | Get-VirtualPortGroup -Name 'VM Network' | Remove-VirtualPortGroup -Confirm:$false
	
#====================================================================================================================
# Rename Default Management Network
#====================================================================================================================
write-host Rename Default Management Network -ForegroundColor Green

Get-VirtualSwitch -name $sw0name | Get-VirtualPortGroup -Name 'Management Network' | Set-VirtualPortGroup -Name $mgmtpgname

#====================================================================================================================
# Add OOB Mgmt VMPG and VLAN
#====================================================================================================================
write-host Add OOB MGMT Port Group and VLAN -ForegroundColor Green	

Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $oobmpgname -VLanId $oobmpgvlan
	
#====================================================================================================================
# Add vCenter Mgmt VMPG and VLAN
#====================================================================================================================
write-host Add vCenter MGMT Port Group and VLAN -ForegroundColor Green	

Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $vcenpgname -VLanId $vcenpgvlan
	
#====================================================================================================================
# Add Nested Labs Mgmt VMPG and VLAN
#====================================================================================================================
write-host Nest LAB MGMT Port Group and VLAN -ForegroundColor Green	

Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $nlabpgname -VLanId $nlabpgvlan
	
#====================================================================================================================
# Add Core Servers Mgmt VMPG and VLAN
#====================================================================================================================
write-host Core Server MGMT Port Group and VLAN -ForegroundColor Green	

Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $corepgname -VLanId $corepgvlan
	
#====================================================================================================================
# Add vMotion VMPG and VLAN
#====================================================================================================================
write-host Add vMotion Port Group and VLAN -ForegroundColor Green	

Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $vmopgname -VLanId $vmovlan
	
#====================================================================================================================
# Add NFS VMPG and VLAN
#====================================================================================================================
write-host Add NFS Port Group and VLAN -ForegroundColor Green	

Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $nfspgname -VLanId $nfsvlan

#====================================================================================================================
# Add iSCSI-A VMPG and VLAN & Edit NIC Teaming Policy
#====================================================================================================================
write-host Add iSCSI-A Port Group and VLAN -ForegroundColor Green
Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $iscsipg1name -VLanId $iscsipg1vlan

write-host Set iSCSI-A NIC vmnic0 Active and vmnic1 Unused -ForegroundColor Green
Get-VirtualPortGroup -Name $iscsipg1name | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $sw0nic0 -MakeNicUnused $sw0nic1
	
#====================================================================================================================
# Add iSCSI-B VMPG and VLAN & Edit NIC Teaming Policy
#====================================================================================================================
write-host Add iSCSI-B Port Group and VLAN -ForegroundColor Green
Get-VirtualSwitch -name $sw0name | New-VirtualPortGroup -Name $iscsipg2name -VLanId $iscsipg2vlan

write-host Set iSCSI-B NIC vmnic1 Active and vmnic0 Unused -ForegroundColor Green
Get-VirtualPortGroup -Name $iscsipg2name | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $sw0nic1 -MakeNicUnused $sw0nic0
	
#====================================================================================================================
# Configure iSCSI vmk (vmk1 /vmk2)
#====================================================================================================================
write-host Add iSCSI IP to vmk1 and vmk2  -ForegroundColor Green
New-VMHostNetworkAdapter -VirtualSwitch $sw0name -PortGroup $iscsipg1name -IP $iscsi1ip -SubnetMask $iscsi1sn
New-VMHostNetworkAdapter -VirtualSwitch $sw0name -PortGroup $iscsipg2name -IP $iscsi2ip -SubnetMask $iscsi2sn

#====================================================================================================================
# Configure vMotion vmk (vmk3)
#====================================================================================================================
write-host Create Provisioning and vMotion TCP/IP stack and add vMotion to VMkernel ports -ForegroundColor Green
$esxcli = Get-EsxCli -VMHost 10.101.18.11 -V2
$esxcli.network.ip.netstack.add.Invoke(@{netstack = ‘vmotion’})
$esxcli.network.ip.interface.add.Invoke(@{interfacename = ‘vmk3’; portgroupname = ‘0017-T-VMO’; netstack = ‘vmotion’})
write-host Statically Assigning IP Address to vmkernel  -ForegroundColor Green
$esxcli.network.ip.interface.ipv4.set.Invoke(@{interfacename = ‘vmk3’; ipv4 = "10.101.17.11"; netmask = "255.255.255.0"; type = "static"})

#====================================================================================================================
# Configure NFS vmk (vmk4)
#====================================================================================================================
write-host Create NFS vmkernel with Static IP Address -ForegroundColor Green

New-VMHostNetworkAdapter -VirtualSwitch $sw0name -PortGroup $nfspgname -IP $nfsip -SubnetMask $nfssn

#====================================================================================================================
# Attach NFS Datastore
#====================================================================================================================
write-host Attach NFS Datastore -ForegroundColor Green
Get-VMHost  | New-Datastore -Nfs -Name $nfs1name  -NfsHost $nfstg1ip -Path $nfs1path
#Get-VMHost  | New-Datastore -Nfs -Name $_.nfs2name -Path /$nfs2path -NfsHost $_.nfspg2ip

	
#====================================================================================================================
# Configure Scratch Location Datastore
#====================================================================================================================
# NEED to create scratch log DataStore 'scratch/esxscratch'
write-host Configure Scratch Location DataStore -ForegroundColor Green
	
Get-VMhost | Get-AdvancedSetting -Name "ScratchConfig.ConfiguredScratchLocation" | Set-AdvancedSetting -Value "/vmfs/volumes/NFS_DS001/scratch/esxscratch" -Confirm:$false
Get-VMhost | Get-AdvancedSetting -Name "Syslog.global.logDirUnique" | Set-AdvancedSetting -Value:$true -Confirm:$false

#====================================================================================================================
# Disconnect from each host
#====================================================================================================================
Disconnect-VIServer $VMHosts -Confirm:$false