$vmnic1 = Get-VMhost | Get-VMHostNetworkAdapter -Physical -Name vmnic1
$vs0 = Get-VirtualSwitch -VMHost $myVMHost -Name 'vSwitch0'
$vs0 | Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmnic1 -Confirm:$false