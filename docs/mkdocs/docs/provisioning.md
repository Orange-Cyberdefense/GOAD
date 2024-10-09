# :material-ansible: provisioning

This page describe how the provisioning is done with goad.
The provisioning of the LABS is done with Ansible for all providers.

- First the GOAD install script create an instance folder in the workspace folder.

## Lab data

The data of each lab are stored in the json file : `ad/<lab>/data/config.json`, this file is loaded by each playbook to get all the lab variables (this is done by the data.yml playbook call by all the over playbooks)

## Extension data

If an extension need data it will be stored in `extensions/<extension>/data/config.json` but the loading must be done by extension install.yml playbook.

- Example with the exchange install.yml file :

```
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

## Inventories

Ansible work with inventories. Inventories files contains all the hosts declaration and some variables.

- The lab inventory file (`ad/<lab>/data/inventory`) is not modified/moved and contain all the main variables and hosts association, this file stay as this and is not modified. It contains the lab building logic.

- The provider inventory file (`ad/<lab>/provider/<provider>/inventory`) is modified with the settings and copied into the workspace folder (`workspace/<instance_id>/inventory`) , this file contains variable specific to the provider and the host ip declaration

- The extension(s) inventory file(s) (`extensions/<extension>/inventory`) is modified with the settings and copied into the workspace folder (`workspace/<instance_id>/inventory_<extension>`) , this file contains variable specific to the extension and the extension host ip declaration

- The global inventory file `globalsettings.ini`contains some global variable with some user settings.


The inventory files are given to ansible in this order :
- lab inventory file
- workspace provider inventory file
- workspace extension(s) inventory file(s)
- globalsettings.ini file

The order is important as it determine the override order. hosts declarations are merged between all inventory and variables with the same name are override if the same variable is declared. 

- Example : if i setup dns_server_forwarder=8.8.8.8 in the lab inventory file and dns_server_forwarder=1.1.1.1 in the globalsettings.ini file, the final value for ansible wll be dns_server_forwarder=1.1.1.1

## playbooks

- Labs playbook are stored on the ansible/ folder
- Extension playbook is stored in `extension/<extension>/ansible/install.yml`
- The extension folder can call the main goad roles by using a special ansible.cfg file.

- Example of the exchange ansible.cfg file
```
[defaults]
...
; add default roles folder into roles_path
roles_path = ./roles:../../../ansible/roles
```

## labs build

- Instead of call a global main.yml playbook with all the different tasks to do the goad script call each playbook one by one.
- In this way, there is a fallback mecanism to retry each playbook 3 times before consider it as failed.
- The list and order of the playbooks played are stored in the playbooks.yml file at the start of the project.