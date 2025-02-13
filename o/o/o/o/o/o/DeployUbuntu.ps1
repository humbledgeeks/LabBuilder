﻿Get-Module -ListAvailable PowerCLI* | Import-Module
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
Connect-VIServer -Server 10.103.16.10




$VM_Name = 'dc3-srv-ubuntu01'
$VM_NumCPU = '8'
$VM_CoresPerSocket = '4'
$VM_MemoryGB = '16'
$VDS_Network = 'dc3-docker (vSAN)'
$Cluster = 'h610c'
$Datastore = 'vsanDatastore'
$VM_Template = 'dc3-srv-ubuntu00'

New-VM -Name $VM_Name -VM $VM_Template -OSCustomizationSpec ubuntu-script -ResourcePool $Cluster -Datastore $Datastore -DiskStorageFormat Thin
sleep 5

Get-VM -Name $VM_Name | Get-NetworkAdapter | Select-Object Parent,MacAddress
Get-VM -Name $VM_Name | Set-VM -MemoryGB $VM_MemoryGB -NumCPU $VM_NumCPU -CoresPerSocket $VM_CoresPerSocket -Confirm:$false
Get-VM -Name $VM_Name | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $VDS_Network -Confirm:$false
Get-VM -Name $VM_Name | Start-VM
Get-VM -Name $VM_Name | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false
Get-VM -Name $VM_Name | Where-Object {$_.powerstate -eq "poweredon"} | Get-NetworkAdapter | Where-object {$_.ConnectionState.StartConnected -ne "True"} | set-networkadapter -startconnected:$true -Confirm:$false
do {
        Start-Sleep -Seconds 10
        $VMStatus = (Get-VM $VM_Name).PowerState
	Write-Host "$($VM_Name) customization is in progress"
    } while ($VMStatus -ne "PoweredOff")
Get-VM -Name $VM_Name | New-Snapshot -Name ClonedCustomized
sleep 5
Get-VM -Name $VM_Name | Start-VM