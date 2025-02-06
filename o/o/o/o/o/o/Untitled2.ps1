$myVMHostNetworkAdapter = Get-VMhost "MyVMHost" | Get-VMHostNetworkAdapter -Physical -Name vmnic2
Get-VirtualSwitch "MyVirtualSwitch" | Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $_.sw0nic1

$vs = Get-VMHost | get-virtualswitch -name $_.sw0nic1
Set-VirtualSwitch -VirtualSwitch $vs -Add-VirtualSwitchPhysicalNetworkAdapter vmnic1 -Mtu 1500 -Confirm:$false