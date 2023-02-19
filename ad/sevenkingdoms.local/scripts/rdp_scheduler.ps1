$task = '/c powershell c:\setup\bot_rdp.ps1'
$repeat = (New-TimeSpan -Minutes 1)
$taskName = "connect_bot"
$user = "north\robb.stark"
$password = "sexywolfy"
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "$task"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $repeat
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
#$settings.CimInstanceProperties.Item('MultipleInstances').Value = 3   # 3 corresponds to 'Stop the existing instance'

$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }
if($taskExists) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -Password $password -Settings $settings