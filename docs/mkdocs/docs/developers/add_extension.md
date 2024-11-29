# Add an extension

- The extension structure MUST be like this :
```
extensions/
    <extension_name>/
        ansible/            # mandatory
            install.yml     # mandatory
        providers/          # mandatory
            aws/
            azure/
            ludus/
            proxmox/
            virtualbox/
            vmware/
        inventory           # mandatory
        extension.json      # mandatory
```
## Create Extension.json

- Create the extension.json file

```json
{
    "name": "my extension",
    "description": "Add an extension to goad lab",
    "machines": [
        "ws02 (myvm.sevenkingdoms.local)"
    ],
    "compatibility": [
        "GOAD",
        "GOAD-Light",
        "GOAD-Mini"
    ],
    "impact": "blabla"
}
```

## Providers

- If the extension need provisioning (new vm) add in each provider folder the vm(s) needed.
- Providers follow the following types
    - Vagrant:
        - vmware
        - virtualbox
    - Terraform:
        - aws
        - azure
        - proxmox
    - Ludus


=== ":simple-vmware: Vmware workstation"
    - As an example to add a new box for vmware :
        - Create the folder `extensions/<extension_name>/providers/vmware/`
        - Add a file named Vagrantfile
        - Add the following code for a linux machine  (and change box, ip, name, cpu, ram):
        ```
        boxes.append(
            { :name => "{{lab_name}}-EXTNAME",
            :ip => "{{ip_range}}.66",
            :box => "bento/ubuntu-22.04", 
            :os => "linux",
            :cpus => 2,
            :mem => 4000,
            :forwarded_port => [ {:guest => 22, :host => 2210, :id => "ssh"} ]
            }
        )
        ```
        - Add the following code for a windows machine (and change box, ip, name, cpu, ram):
        ```
        # add windows box
        boxes.append(
            { :name => "{{lab_name}}-EXTNAME",
                :ip => "{{ip_range}}.66",
                :box => "mayfly/windows10",
                :os => "windows",
                :cpus => 2,
                :mem => 4000
            }
        )
        ```

=== ":simple-virtualbox: Virtualbox"
    - As an example to add a new box for virtualbox :
        - Create the folder `extensions/<extension_name>/providers/virtualbox/`
        - Add a file named Vagrantfile
        - Add the following code for a linux machine  (and change box, ip, name, cpu, ram):
        ```
        boxes.append(
            { :name => "{{lab_name}}-EXTNAME",
            :ip => "{{ip_range}}.66",
            :box => "bento/ubuntu-22.04", 
            :os => "linux",
            :cpus => 2,
            :mem => 4000,
            :forwarded_port => [ {:guest => 22, :host => 2210, :id => "ssh"} ]
            }
        )
        ```
        - Add the following code for a windows machine (and change box, ip, name, cpu, ram):
        ```
        # add windows box
        boxes.append(
            { :name => "{{lab_name}}-EXTNAME",
                :ip => "{{ip_range}}.66",
                :box => "mayfly/windows10",
                :os => "windows",
                :cpus => 2,
                :mem => 4000
            }
        )
        ```

=== ":material-microsoft-azure: Azure"
    - As an example to add a new box for azure :
        - Create the folder `extensions/<extension_name>/providers/azure/`
        - Add a file (linux.tf or windows.tf) depending of the type of vm
        - For a linux box (linux.tf file) (change box sku, ip, name, box size):
        ```
        "vmname" = {
            name               = "vmname"
            linux_sku          = "22_04-lts-gen2"
            linux_version      = "latest"
            private_ip_address = "{{ip_range}}.51"
            password           = "rootpassword"
            size               = "Standard_B2s"  # 2cpu/4G
            }
        ```
        - For a windows box (windows.tf file) (change box sku, ip, name, box size):
        ```
        "vmname" = {
            name               = "vmname"
            publisher          = "MicrosoftWindowsServer"
            offer              = "WindowsServer"
            windows_sku        = "2019-Datacenter"
            windows_version    = "17763.4377.230505"
            private_ip_address = "{{ip_range}}.10"
            password           = "goadadmin_password"
            size               = "Standard_B2s"  # 2cpu/4G
        }
        ```

=== ":simple-amazon: Aws"
    - As an example to add a new box for aws :
        - Create the folder `extensions/<extension_name>/providers/aws/`
        - Add a file (linux.tf or windows.tf) depending of the type of vm
        - For a linux box (linux.tf file) (change box sku, ip, name, box size):
        ```
        "vmname" = {
            name               = "vmname"
            linux_sku          = "22_04-lts-gen2"
            linux_version      = "latest"
            ami                = "ami-00c71bd4d220aa22a"
            private_ip_address = "{{ip_range}}.51"
            password           = "sgdvnkjhdshlsd"
            size               = "t2.medium"
        }
        ```
        - For a windows box (windows.tf file) (change box sku, ip, name, box size):
        ```
        "vmname" = {
            name               = "vmname"
            domain             = "sevenkingdoms.local"
            windows_sku        = "2019-Datacenter"
            ami                = "ami-018ebfbd6b0a4c605"
            instance_type      = "t2.medium"
            private_ip_address = "{{ip_range}}.21"
            password           = "goadadmin_password"
        }
        ```
        - Find AMI example :
        ```
        aws ec2 describe-images \
          --owners "amazon" \
          --filters "Name=name,Values=Windows_Server-2019-English-Full-Base*" \ 
          --query "Images[*].{ImageId:ImageId,Name:Name,CreationDate:CreationDate,Description:Description}" \
          --output table
        ```

=== ":simple-proxmox: Proxmox"
    - As an example to add a new box for proxmox :
        - Create the folder `extensions/<extension_name>/providers/proxmox/`
        - Add a file (linux.tf or windows.tf) depending of the type of vm
        - For a linux box (linux.tf file) (and change characteristics):
        ```
        "vmname" = {
            name               = "vmname"
            desc               = "vmname - ubuntu 22.04 - {{ip_range}}.10"
            cores              = 4
            memory             = 12000
            clone              = "Ubuntu2204_x64"
            dns                = "{{ip_range}}.1"
            ip                 = "{{ip_range}}.21/24"
            gateway            = "{{ip_range}}.1"
        }
        ```
        - For a windows box (windows.tf file) (and change characteristics):
        ```
        "vmname" = {
            name               = "vmname"
            desc               = "vmname - windows server 2019 - {{ip_range}}.10"
            cores              = 4
            memory             = 12000
            clone              = "WinServer2019_x64"
            dns                = "{{ip_range}}.1"
            ip                 = "{{ip_range}}.21/24"
            gateway            = "{{ip_range}}.1"
        }
        ```

    !!! warning
        be sure to have the template ready to get clone (you should prepare it with packer first)

=== "🏟️  Ludus"
    - As an example to add a new box for ludus :
        - Create the folder `extensions/<extension_name>/providers/ludus/`
        - Add a file config.yml
        - For a linux box (linux.tf file) (and change characteristics):
        ```
        - vm_name: "{{ range_id }}-name"
            hostname: "{{ range_id }}-name"
            template: ubuntu-22.04-x64-server-template
            vlan: 10
            ip_last_octet: 66
            ram_gb: 8
            cpus: 2
            linux: true
        ```
        - For a windows box (windows.tf file) (and change characteristics):
        ```
        - vm_name: "{{ range_id }}-name"
            hostname: "{{ range_id }}-name"
            template: win2019-server-x64-template
            vlan: 10
            ip_last_octet: 66
            ram_gb: 4
            cpus: 4
            windows:
                sysprep: true
        ```

    !!! warning
        be sure to have the template ready before see [https://docs.ludus.cloud/docs/templates](https://docs.ludus.cloud/docs/templates)

## Ansible inventory
- Create the ansible inventory file : `extension/<extension_name>/inventory`
- an example could be :

```ini
[default]
wazuh ansible_host={{ip_range}}.51 ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[extensions]
wazuh

; Recipe associations -------------------
[wazuh_server]
wazuh

[wazuh_agents:children]
domain
```

or for a windows machine associated to a domain:

```ini
[default]
{% if provider_name == 'aws' or provider_name == 'azure' %}
ws01 ansible_host={{ip_range}}.31 dns_domain=dc01 dict_key=ws01 ansible_user=ansible ansible_password=EP+xh7Rk6j90
{% else %}
ws01 ansible_host={{ip_range}}.31 dns_domain=dc01 dict_key=ws01
{% endif %}

[domain]
ws01

[extensions]
ws01
```

- Domain contains all the windows vm associated with a domain. You can install something on all of them by using :

```ini
[inventory_group:children]
domain
```

- If you want to add your new vm to that group just add it and it will be merge with the main inventory:

```ini
[domain]
vm_name
```


## Ansible tasks and roles

The providers to add the vms you need are setup, now you should add the provisioning part.

To do that you must add the file `extension/<extension_name>/ansible/install.yml`

The file should be the following:

```yaml
- name: task name
  hosts: host_group_according_to_the_inventory
  become: yes
  roles:
    - { role: '<role_name>', tags: '<tag_role_name>'}
  vars:
    role_variable: "value"
```

You should create each ansible role you use in `extension/<extension_name>/ansible/roles/<role_name>`

- If you need to use goad roles you can include it by creating an ansible.cfg file with the following contents:

```ini
# extension/<extension_name>/ansible/ansible.cfg
[defaults]
host_key_checking = false
display_skipped_hosts = false
show_per_host_start     = True
deprecation_warning   = false
;stdout_callback         = yaml

; add default roles folder into roles_path
roles_path = ./roles:../../../ansible/roles
```

- If you need the lab data for your extension add the following code on the start of the install.yml file:

```yaml
# read global configuration file and set up adapters
- import_playbook: "../../../ansible/data.yml"
  vars:
    data_path: "../ad/{{domain_name}}/data/"
  tags: 'data'
```

- If you need to combine the lab data with your own json config file add to the install.yml :

```yaml
# read local configuration file
- name: "Read local config file"
  hosts: domain:extensions
  connection: local
  vars_files:
    - "../data/config.json"
  tasks:
    - name: merge lab variable with local config
      set_fact:
        lab: "{{ lab|combine(lab_extension, recursive=True) }}"
```

- and create the json file in `extension/<extension_name>/data/config.json`

```json
{
    "lab_extension": {
        "hosts": {
            ...
        },
        "domains": {
            ...
        }
}
```