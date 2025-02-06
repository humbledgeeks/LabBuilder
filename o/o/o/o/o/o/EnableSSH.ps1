##Enable SSH##
Get-VMHostService -VMHost $vmhost | Where-Object {$_.Key -eq "TSM-SSH"} | Set-VMHostService -policy "on" -Confirm:$false
Get-VMHostService -VMHost $vmhost | Where-Object {$_.Key -eq "TSM-SSH"} | Restart-VMHostService -Confirm:$false
Get-VMHost $VMHost | Get-AdvancedSetting UserVars.SuppressShellWarning | Set-AdvancedSetting -Value 1 -Confirm:$false