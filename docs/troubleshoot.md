## Troubleshooting

- In most case if you get errors during install, don't think and just replay the main playbook (most of the errors which could came up are due to windows latency during installation, wait few minutes and replay the install)

## Groups domain error

- something go wrong with the trust, all the links are not fully establish
- wait several minutes and relaunch the playbook
- i really don't know why this append time to time on installation, if you want to investigate and resolve the issue please tell me how.

```bash
An exception occurred during task execution. To see the full traceback, use -vvv. The error was:    at Microsoft.ActiveDirectory.Management.Commands.ADCmdletBase`1.BeginProcessing()
failed: [192.168.56.xx] (item={'key': 'DragonsFriends', 'value': ['sevenkingdoms.local\\tyron.lannister', 'essos.local\\daenerys.targaryen']}) => {"ansible_loop_var": "item", "attempts": 3, "changed": false, "item": {"key": "DragonsFriends", "value": ["north.sevenkingdoms.local\\jon.snow", "sevenkingdoms.local\\tyron.lannister", "essos.local\\daenerys.targaryen"]}, "msg": "Unhandled exception while executing module: Either the target name is incorrect or the server has rejected the client credentials."}
```

## Error Add-Warning

- You got an "Add-Warning" error during the user installation.
- Upgrade to community.windows galaxy >= 1.11.0
- relaunch the ansible playbooks.

```bash
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: at , : line 475
failed: [192.168.56.11] (item={'key': 'arya.stark', 'value': {'firstname': 'Arya', 'surname': 'Stark',
...
"msg": "Unhandled exception while executing module: The term 'Add-Warning' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again."}+
```

## A parameter cannot be found that matches parameter name 'AcceptLicense'

- If you got this kind of error you got an ansible.windows version >=  1.11.0
- This version add the parameter AcceptLicense but it is accepted only for PowerShellGet module >= 1.6.0 and this one is not embededded in the vms.
- Please keep version 1.11.0 and update the lab to get the fix for the PowerShellGet Module version.

```bash
fatal: [xxx]: FAILED! => {
    "changed": false,
    "msg": "Problems installing XXXX module: A parameter cannot be found that matches parameter name 'AcceptLicense'.",
    "nuget_changed": false,
    "output": "",
    "repository_changed": false
}
```

## old Ansible version

```bash
ERROR! no action detected in task. This often indicates a misspelled module name, or incorrect module path.
 
The error appears to have been in '/home/hrrb0032/Documents/mission/GOAD/roles/domain_controller/tasks/main.yml': line 8, column 3, but maybe elsewhere in the file depending on the exact syntax problem.
 
The offending line appears to be:
 
- name: disable enhanced exit codes
^ here
```

solution : upgrade Ansible

### old ansible.windows version
```bash
ERROR! couldn't resolve module/action 'win_powershell'. This often indicates a misspelling, missing collection, or incorrect module path.
```

- solution: reinstall ansible.windows module :
```bash
ansible-galaxy collection install ansible.windows --force
```

## winrm

```bash
PLAY [DC01 - kingslanding] *******************************************************

 

TASK [Gathering Facts] ***********************************************************
fatal: [192.168.56.10]: FAILED! => {"msg": "winrm or requests is not installed: No module named winrm"}

 

PLAY RECAP ***********************************************************************
192.168.56.10              : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

solution : pip install pywinrm



## winrm send input timeout

```bash
TASK [Gathering Facts] ****************************************************************************************************************************************************
[WARNING]: ERROR DURING WINRM SEND INPUT - attempting to recover: WinRMOperationTimeoutError
ok: [192.168.56.11]
```

solution : wait or if crashed then re-run install



## Domain controller : ensure Users are present 

```bash
TASK [domain_controller : Ensure that Users presents in ou=<kingdom>,dc=SEVENKINGDOMS,dc=local] ***************************************************************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was:    at Microsoft.ActiveDirectory.Management.Commands.ADCmdletBase`1.ProcessRecord()
failed: [192.168.56.10] (item={u'key': u'lord.varys', u'value': {u'city': u"King's Landing", u'password': u'_W1sper_$', u'name': u'Lord Varys', u'groups': u'Small Council', u'path': u'OU=Users,OU=Crownlands,OU=kingdoms,DC=SEVENKINGDOMS,DC=local'}}) => {"ansible_loop_var": "item", "changed": false, "item": {"key": "lord.varys", "value": {"city": "King's Landing", "groups": "Small Council", "name": "Lord Varys", "password": "_W1sper_$", "path": "OU=Users,OU=Crownlands,OU=kingdoms,DC=SEVENKINGDOMS,DC=local"}}, "msg": "Unhandled exception while executing module: An unspecified error has occurred"}

```
 solution : re-run install

## mssql : Unable to install SQL Server
```
TASK [mssql : Install the database]
fatal: [192.168.56.22]: FAILED! => {"attempts": 3, "changed": true, "cmd": "c:\\setup\\mssql\\sql_installer.exe /configurationfile=c:\\setup\\mssql\\sql_conf.ini /IACCEPTSQLSERVERLICENSETERMS /MEDIAPATH=c:\\setup\\mssql\\media /QUIET /HIDEPROGRESSBAR", "delta": "0:00:34.891185", "end": "2022-08-17 21:26:53.976793", "msg": "non-zero return code", "rc": 2226323458, "start": "2022-08-17 21:26:19.085608", "stderr": "", "stderr_lines": [], "stdout": "Microsoft (R) SQL Server Installer\r\nCopyright (c) 2019 Microsoft.  All rights reserved.\r\n\r\nDownloading install package...\r\n\r\n\r\nOperation finished with result: Failure\r\n\r\nOops...\r\n\r\nUnable to install SQL Server (setup.exe).\r\n\r\n      Exit code (Decimal): -2068643838\r\n      Exit message: No features were installed during the setup execution. The requested features may already be installed. Please review the summary.txt log for further details.\r\n\r\n  SQL SERVER INSTALL LOG FOLDER\r\n      c:\\Program Files\\Microsoft SQL Server\\150\\Setup Bootstrap\\Log\\20220817_142624\r\n\r\n", "stdout_lines": ["Microsoft (R) SQL Server Installer", "Copyright (c) 2019 Microsoft.  All rights reserved.", "", "Downloading install package...", "", "", "Operation finished with result: Failure", "", "Oops...", "", "Unable to install SQL Server (setup.exe).", "", "      Exit code (Decimal): -2068643838", "      Exit message: No features were installed during the setup execution. The requested features may already be installed. Please review the summary.txt log for further details.", "", "  SQL SERVER INSTALL LOG FOLDER", "      c:\\Program Files\\Microsoft SQL Server\\150\\Setup Bootstrap\\Log\\20220817_142624", ""]}
```

solution : re-run installer