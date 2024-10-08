# troubleshoot

!!! tip
    In most case if you get errors during install, don't think. 
    Select the failed instance ̀`load <instance_id>` and just replay the install with `provision_lab` to relaunch all or `provision_lab_from <playbook>` if you know the last failed playbook 
    (most of the errors which could came up are due to windows latency during installation, wait few minutes and replay the install)

🚧 TODO refresh me with new goad version :)


## vagrant up - WinRM - digest initialization failed : Initialization Error

```
DC01: WinRM username: vagrant
DC01: WinRM execution_time_limit: PT2H
DC01: WinRM transport: negotiate
An error occurred executing a remote WinRM command.

Shell: Cmd
Command: hostname
Message: Digest initialization failed: initialization error
```

- solution 1: change vagrantfile to not use ssl (https://github.com/Orange-Cyberdefense/GOAD/issues/68)
    - add this lines in vagrantfile to not use ssl :
        ```
        config.winrm.transport = "plaintext"
        config.winrm.basic_auth_only = true
        ```
- solution 2: allow legacy algorithm (https://github.com/Orange-Cyberdefense/GOAD/issues/11)
    - add to /etc/ssl/openssl.conf :
    ```
    [provider_sect]
    default = default_sect
    legacy = legacy_sect

    [default_sect]
    activate = 1

    [legacy_sect]
    activate = 1
    ```

- solution 3: downgrade the vagrant version (`sudo apt install vagrant=2.2.19`)

## vagrant up - cannot load 

```
<internal:/usr/lib/ruby/vendor_ruby/rubygems/core_ext/kernel_require.rb>:85:in `require': cannot load such file -- winrm (LoadError)
	from <internal:/usr/lib/ruby/vendor_ruby/rubygems/core_ext/kernel_require.rb>:85:in `require'
	from /usr/share/rubygems-integration/all/gems/vagrant-2.3.4/plugins/communicators/winrm/shell.rb:9:in `block in <top (required)>'
	from /usr/share/rubygems-integration/all/gems/vagrant-2.3.4/lib/vagrant/util/silence_warnings.rb:8:in `silence!'
```

- solution : 
  - `gem install winrm`
  - `gem install winrm-fs`


## vagrant up - cannot load such file -- winrm-elevated (LoadError)

```
<internal:/usr/lib/ruby/vendor_ruby/rubygems/core_ext/kernel_require.rb>:85:in `require': cannot load such file -- winrm-elevated (LoadError)
        from <internal:/usr/lib/ruby/vendor_ruby/rubygems/core_ext/kernel_require.rb>:85:in `require'
        from /usr/share/rubygems-integration/all/gems/vagrant-2.3.4/plugins/communicators/winrm/shell.rb:12:in `<top (required)>'
        ...
```

- solution : `gem install winrm-elevated`


## ansible persistent "unreachable error"

- Unreachable means ansible can't contact the vms. 
- Maybe the vms didn't got the right ip? (try to connect with vagrant/vagrant on vm and look the ip)
- Or you got a firewall on the vm which do provisioning which block winrm connection ?
- or maybe it is a vagrant issue : https://github.com/Orange-Cyberdefense/GOAD/issues/12
- You could try to switch on port 5985 to connect without ssl as suggest here : https://github.com/Orange-Cyberdefense/GOAD/issues/98 by uncomment the lines in the inventory file you use
```
# ansible_winrm_transport=basic
# ansible_port=5985
```

## The naming context specified for this replication operation is invalid

```
TASK [groups_domains : synchronizes all domains] *******************************************************************************************************************************************************************************************************************************
changed: [dc03]
changed: [dc01]
fatal: [dc02]: FAILED! => {"changed": true, "cmd": "repadmin /syncall /Ade", "delta": "0:00:01.090773", "end": "2023-10-18 09:30:26.016579", "msg": "non-zero return code", "rc": 1, "start": "2023-10-18 09:30:24.925805", "stderr": "", "stderr_lines": [], "stdout": "Syncing all NC's held on winterfell.\r\r\nSyncing partition: DC=north,DC=sevenkingdoms,DC=local\r\r\nCALLBACK MESSAGE: Error contacting server CN=NTDS Settings,CN=WINTERFELL,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=sevenkingdoms,DC=local (network error): 1722 (0x6ba):\r\r\n    The RPC server is unavailable.\r\r\n\r\r\nSyncAll exited with fatal Win32 error: 8440 (0x20f8):\r\r\n    The naming context specified for this replication operation is invalid.\r\r\n", "stdout_lines": ["Syncing all NC's held on winterfell.", "", "Syncing partition: DC=north,DC=sevenkingdoms,DC=local", "", "CALLBACK MESSAGE: Error contacting server CN=NTDS Settings,CN=WINTERFELL,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=sevenkingdoms,DC=local (network error): 1722 (0x6ba):", "", "    The RPC server is unavailable.", "", "", "", "SyncAll exited with fatal Win32 error: 8440 (0x20f8):", "", "    The naming context specified for this replication operation is invalid.", ""]}
```

- relaunch install

## vagrant up - Vagrant can't use the requested machine because it is locked 

```
==> GOAD-SRV03: Configuring and enabling network interfaces...
Vagrant can't use the requested machine because it is locked! This
means that another Vagrant process is currently reading or modifying
the machine. Please wait for that Vagrant process to end and try
again. Details about the machine are shown below:
```

- solution : relaunch the provisioning on the broken computer : 
- exemple :
```
cd ~/GOAD/ad/GOAD/providers/virtualbox
vagrant reload GOAD-SRV03 --provisioning
```
- and than relaunch the install script

## The server has rejected the client credentials

```
An exception occurred during task execution. To see the full traceback, use -vvv. The error was:    at Microsoft.ActiveDirectory.Management.Commands.ADCmdletBase`1.BeginProcessing()
failed: [dc02] (item={'key': 'AcrossTheSea', 'value': ['essos.local\\daenerys.targaryen']}) => {"ansible_loop_var": "item", "attempts": 3, "changed": false, "item": {"key": "AcrossTheSea", "value": ["essos.local\\daenerys.targaryen"]}, "msg": "Unhandled exception while executing module: The server has rejected the client credentials."}
```

- something go wrong with the trust, all the links are not fully establish
- wait several minutes and relaunch the install

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
- This version add the parameter AcceptLicense but it is accepted only for PowerShellGet module >= 1.6.0 and this one is not embedded in the vms.
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


## vagrant: Not working on Ubuntu 22.04

I was using the version of Vagrant in the Ubuntu repo, and then tried to use the version 2.4.0 and 2.3.4 binaries from hashicorp, but kept on running into this error:

```
The guest machine entered an invalid state while waiting for it
to boot. Valid states are 'starting, running'. The machine is in the
'poweroff' state. Please verify everything is configured
properly and try again.

If the provider you're using has a GUI that comes with it,
it is often helpful to open that and watch the machine, since the
GUI often has more helpful error messages than Vagrant can retrieve.
For example, if you're using VirtualBox, run `vagrant up` while the
VirtualBox GUI is open.

The primary issue for this error is that the provider you're using
is not properly configured. This is very rarely a Vagrant issue.
```
Solution : install vagrant from the hashicorp repo

## proxmox: error creating VM: 403 Permission check failed (/sdn/zones/localnetwork/vmbr3/10, SDN.Use)

The error may look similar to below:
```
==> proxmox-iso.windows: Error creating VM: error creating VM: 403 Permission check failed (/sdn/zones/localnetwork/vmbr3/10, SDN.Use), 
error status: {"data":null} (params: ......
```

It may be fixed by delegating the SDN.Use privilege to the packer user
```
pveum role modify Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory Datastore.AllocateTemplate Datastore.Audit Datastore.AllocateSpace Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Cloudinit VM.Config.Network VM.PowerMgmt VM.Config.HWType VM.Monitor SDN.Use"
```

## proxmox: ==> proxmox-iso.windows: Error creating VM: error creating VM: unable to create VM 103 - unsupported format 'qcow2' 

The error may look similar to below:
```
root@goadprovisioning:~/GOAD/packer/proxmox# packer build -var-file=windows_server2019_proxmox_cloudinit.pkvars.hcl .
proxmox-iso.windows: output will be in this color.

==> proxmox-iso.windows: Retrieving additional ISO
==> proxmox-iso.windows: Trying ./iso/Autounattend_winserver2019_cloudinit.iso
==> proxmox-iso.windows: Trying ./iso/Autounattend_winserver2019_cloudinit.iso?checksum=sha256%3A43857cb780de3a58696285f644034499d4b29608b3c511feb27e315832b696c4
==> proxmox-iso.windows: ./iso/Autounattend_winserver2019_cloudinit.iso?checksum=sha256%3A43857cb780de3a58696285f644034499d4b29608b3c511feb27e315832b696c4 => /root/GOAD/packer/proxmox/iso/Autounattend_winserver2019_cloudinit.iso
    proxmox-iso.windows: Uploaded ISO to local:iso/Autounattend_winserver2019_cloudinit.iso
==> proxmox-iso.windows: Creating VM
==> proxmox-iso.windows: No VM ID given, getting next free from Proxmox
==> proxmox-iso.windows: Error creating VM: error creating VM: unable to create VM 103 - unsupported format 'qcow2' at /usr/share/perl5/PVE/Storage/LvmThinPlugin.pm line 87., error status:  (params: map[agent:1 args: boot: cores:2 cpu:kvm64 description:Packer ephemeral build VM hotplug: ide2:local:iso/windows_server_2019.iso,media=cdrom kvm:true machine: memory:4096 name:WinServer2019x64-cloudinit-qcow2 net0:virtio=5E:5D:24:C4:0F:DA,bridge=vmbr3,tag=10 numa:false onboot:false ostype:win10 pool:GOAD sata0:vms:40,discard=ignore,format=qcow2 scsihw:lsi sockets:1 startup: tags: vmid:103])......
```

Filesystems such as ZFS (and others) do not support qcow2. From my reading the best approach is to use an ext4 filesystem and modify `config.auto.pkrvars.hcl` with the newly created ext4 volume.

```
root@goadprovisioning:~/GOAD/packer/proxmox# vi config.auto.pkrvars.hcl
...
proxmox_vm_storage      = "ext4-qcow2"
...
root@goadprovisioning:~/GOAD/packer/proxmox# packer build -var-file=windows_server2019_proxmox_cloudinit.pkvars.hcl .
proxmox-iso.windows: output will be in this color.

==> proxmox-iso.windows: Retrieving additional ISO
==> proxmox-iso.windows: Trying ./iso/Autounattend_winserver2019_cloudinit.iso
==> proxmox-iso.windows: Trying ./iso/Autounattend_winserver2019_cloudinit.iso?checksum=sha256%3A43857cb780de3a58696285f644034499d4b29608b3c511feb27e315832b696c4
==> proxmox-iso.windows: ./iso/Autounattend_winserver2019_cloudinit.iso?checksum=sha256%3A43857cb780de3a58696285f644034499d4b29608b3c511feb27e315832b696c4 => /root/GOAD/packer/proxmox/iso/Autounattend_winserver2019_cloudinit.iso
    proxmox-iso.windows: Uploaded ISO to local:iso/Autounattend_winserver2019_cloudinit.iso
==> proxmox-iso.windows: Creating VM
==> proxmox-iso.windows: No VM ID given, getting next free from Proxmox
==> proxmox-iso.windows: Starting VM
```

- another solution is to switch to raw : `proxmox_vm_storage      = "raw"`

## proxmox - packer error creating vm :  volume 'local:iso/windows_XXX.iso' does not exist

```
==> proxmox-iso.windows: Error creating VM: error creating VM: unable to create VM 116 - volume 'local:iso/windows_server2019_XXX_en-us.iso' does not exist, error status:  (params: map[agent:1 args: boot: cores:2 cpu:kvm64 description:Packer ephemeral build VM hotplug
: ide2:local:iso/windows_server2019_XXX_en-us.iso,media=cdrom kvm:true machine: memory:4096 name:WinServer2019x64-cloudinit-qcow2-uptodate net0:virtio=DA:CB:EB:85:08:0E,bridge=vmbr3,tag=10,firewall=false onboot:false ostype:win10 pool:Templates sata0:local:80,format=q
cow2 scsihw:lsi sockets:1 startup: tags: vmid:116])   
```

verify your iso files inside proxmox and be sure the iso you want to use exist in proxmox

## ansible adapter name error 

```
No MSFT_NetAdapter objects found with property 'Name' equal to 'Ethernet'

or 

No MSFT_NetAdapter objects found with property 'Name' equal to 'Ethernet2 '
```

- connect to the vm and run ipconfig, verify the adapter name are the same as described in the inventory file.
- if not change them to match the inventory name in the vm.

## unreachable - proxmox, ansible
```
fatal: [dc01]: UNREACHABLE! => {"changed": false, "msg": "ssl: HTTPSConnectionPool(host='192.168.10.40', port=5986): Max retries exceeded with url: /wsman
```

- may be the vm is not well ready after the terraform creation. retry the install.
- if you still get the error connect to the vm and verify the static ip is corresponding with the one expect.


