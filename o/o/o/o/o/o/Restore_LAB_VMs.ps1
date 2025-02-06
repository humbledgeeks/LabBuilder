$snapname = '2023-05-26T2055'
Connect-VIServer -Server dc1-hst-mgmt1.humbledgeeks.com
$vms = Get-VM -Location lab-scripts | 
    ForEach-Object {$vms.name} {
        Stop-VM $_.name -Confirm:$false
        Set-VM $_.name -Snapshot $snapname -Confirm:$false
        Start-VM $_.name -Confirm:$false
        }
Disconnect-VIServer -Confirm:$false
