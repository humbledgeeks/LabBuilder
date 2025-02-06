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
$VIBPATH = "/vmfs/volumes/NFS_DS001/NetAppNasPlugin_2.0.1-16.vib"
$datastore = Get-Datastore "NFS_DS001"
#====================================================================================================================
# Connect to each host
#====================================================================================================================

write-host Connecting to vCenter Server instance -ForegroundColor Green
Connect-VIServer -Server $VMHosts -User $esxiuser -Password $esxipass



# Install NETAPP NFS VIBs
Write-host Installing NetApp VAAI NFS VIB -ForegroundColor Green
$arguments = $esxcli.software.vib.install.CreateArgs()
$arguments.viburl = $VIBPATH
$arguments.nosigcheck = $true
$esxcli.software.vib.install.invoke($arguments)


Disconnect-VIServer $VMHosts -Confirm:$false

