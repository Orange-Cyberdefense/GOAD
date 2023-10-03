# Default template

You can use this template to create your own lab

## Inventory file : Inventory

This is the ansible inventory file.

- All the vms defined in the vagrant file must be set here.
- This will do the mapping between IP and the configuration file (data/config.json)
```
[default]
dc01 ansible_host=192.168.56.10 dns_domain=dc01 dict_key=dc01
srv01 ansible_host=192.168.56.11 dns_domain=dc01 dict_key=srv01
```

- Vm defined in the inventory must be set into the groups to run the associated roles

## Inventory file : roles

### domain (mandatory)
- all computers inside domain (mandatory)
- usage : build.yml, ad-relations.yml, ad-servers.yml, vulnerabilities.yml

### domain controller (mandatory)
- usage : ad-acl.yml, ad-data.yml, ad-relations.yml, laps.yml
- all domain controller must be declared here

### server (mandatory if you want servers)
- domain server to enroll (mandatory if you want servers)
- usage : ad-data.yml, ad-servers.yml, laps.yml

### parent_dc (mandatory)
- parent domain controller mandatory even if you don't use child dc
- usage : ad-servers.yml

### child_dc (optional)
- child domain controller (need a fqdn child_name.parent_name)
- usage : ad-servers.yml

### trust (optional)
- external trust, need domain trust key in config (bidirectionnal)
- usage : ad-trusts.yml

### adcs (optional)
- Install adcs
- usage : adcs.yml

### adcs_customtemplates (optional)
- install custom templates on the dc
- usage : adcs.yml
- by now the template are hardcoded for esc1-4

### iis (optional)
- install iis with default website asp upload on 80
- usage : servers.yml

### mssql (optional)
- install mssql (need the configuration defined in config.json)
- usage : servers.yml

### mssql_ssms (optional)
- install mssql gui (does not work on windows server 2016 by default)
- usage : servers.yml

### webdav (optional)
- install webdav
- usage : servers.yml

### elk_server (optional)
- install elk
- usage : elk.yml
- this group is just for the elk linux server

### elk_log (optional)
- add log agent for elk
- usage : elk.yml
- this group is for all windows vm where we want to setup the elk agent

### update (optional)
- allow computer update (by default yes)
- usage : update.yml

### no_update (optional)
- disable computer update
- usage : update.yml

### defender_on (optional)
- enable defender (by default defender is enabled on windows)
- usage : security.yml

### defender_off (optional)
- disable defender
- usage : security.yml

## Configuration file : data/config.json

```
"lab" : {
    "hosts" : {
       # here the hosts configuration
    },
    "domains" : {
        # domain configuration
    }
```

### Configuration file : hosts

The host configuration contain one key by host : **the key must match the dict_key in inventory**

- Example : 
```
    "hosts" : {
        "dc01" : {
            "hostname" : "dctemplate",
            "local_admin_password": "dc_and_domain_password",
            "domain" : "template.lab",
            "path" : "DC=template,DC=lab",
            "local_groups" : {
                "Administrators" : [
                    "template\\dcadmins"
                ]
            },
            "scripts" : ["features.ps1"],
            "vulns" : ["files"],
            "vulns_vars" : {
                "files" : {
                    "rdp" : {
                        "src" : "flag.txt",
                        "dest" : "c:\\users\\administrators\\desktop\\flag.txt"
                    }
                }
            }
        },
```

- hostname : here put the hostname of the host
- type : [dc|server] this variable is not read by now but could be used in the future
- local_admin_password : the administrator password (if the host is a domain controler, this password will be used as the administrator password of the domain)
- domain : the domain of the host
- path: the path in the domain
- local_groups: here you can make local modifications to the vm local groups
- scripts : if you want to play some custom ps1 scripts present in the scripts/ folder (be carrefull to make script than can be played multiple times in case the provisioning crash and you want to rerun all the steps)
- vulns : this contains specifics roles presents in ansible/roles/vulns
- vulns_vars : this contains the variables for the vuln roles you want to run
- use_laps(optional) : true|false  if you want to use laps on this hosts (servers only)
- mssql(optional) : if you add the host to the [mssql] role in the inventory, you should add all the mssql special variables (see the mssql part)

#### use_laps (optional, default false)

```
"use_laps": true,
```

- Define if laps must be deployed on this hosts, value : true or false

#### mssql (for mssql role)

- To install and configure mssql you should add the host where you want it installed in your inventory file :

```
; install mssql on these hosts
; usage : servers.yml
[mssql]
srv02
srv03

; install mssql gui on these hosts (don't work on windows server 2016)
; usage : servers.yml
[mssql_ssms]
srv02
```

- If you add mssql you should add the following variables in the corresponding host in the configuration file, this is mandatory

- Example on srv03
```
"hosts" : {
    "srv03" : {
        ...
        "mssql":{
            "sa_password": "sa_P@ssw0rd!Ess0s",
            "svcaccount" : "sql_svc",
            "sysadmins" : [
                "ESSOS\\khal.drogo"
            ],
            "executeaslogin" : {
                "ESSOS\\jorah.mormont" : "sa"
            },
            "executeasuser" : {},
            "linked_servers": {
                "CASTELBLACK" : {
                    "data_src": "castelblack.north.sevenkingdoms.local",
                    "users_mapping": [
                        {"local_login": "ESSOS\\khal.drogo","remote_login": "sa", "remote_password": "Sup1_sa_P@ssw0rd!"}
                    ]
                }
            }
        }
```


### Configuration file : domains

- The domains part is where you configure your active directory domain
- You should setup on key for each domain (here template.lab)
- The key should match the domain key defined on the host part

```
"domains" : {
    "template.lab" : {
            "dc": "dc01",
            "domain_password" : "dc_and_domain_password",
            "netbios_name": "TEMPLATE",
            "groups" : {
                "universal" : {},
                "domainlocal" : {},
                "global" : {
                    "admins" : {
                        "managed_by" : "alice",
                        "path" : "CN=Users,DC=template,DC=lab"
                    },
                    "srvadmins" : {
                        "managed_by" : "bob",
                        "path" : "CN=Users,DC=template,DC=lab"
                    }
                }
            },
            "users" : {
                "alice" : {
                    "firstname"   : "alice", "surname": "",
                    "password"    : "aupaysdesmerveilles", 
                    "description" : "",
                    "groups"      : ["dcadmins","srvadmins"],
                    "path"        : "CN=Users,DC=template,DC=lab"
                },
                "bob" : {
                    "firstname"   : "bob", "surname": "",
                    "password"    : "lebricoleur",
                    "description" : "",
                    "groups"      : ["srvadmins"],
                    "path"        : "CN=Users,DC=template,DC=lab"
                }
            }
        }
    }
```

- dc : this is the matching host key for the primary domain controler
- domain_password : this must be the same as the administrator password of the primary domain controler
- netbios_name: the netbios name of the domain
- groups : here you can define "universal","global" or "domainlocal" groups
- users : here you will define all your domain users each key match the user created

#### organisation_units (optional)
- To add custom organisation units (OU)

- Example on sevenkingdoms.local :
```
"domains" : {
    "sevenkingdoms.local" : {
            ...
            "organisation_units" : {
                "Vale"        : { "path" : "DC=sevenkingdoms,DC=local"},
                "IronIslands" : { "path" : "DC=sevenkingdoms,DC=local"},
                "Riverlands"  : { "path" : "DC=sevenkingdoms,DC=local"},
                "Crownlands"  : { "path" : "DC=sevenkingdoms,DC=local"},
                "Stormlands"  : { "path" : "DC=sevenkingdoms,DC=local"},
                "Westerlands" : { "path" : "DC=sevenkingdoms,DC=local"},
                "Reach"       : { "path" : "DC=sevenkingdoms,DC=local"},
                "Dorne"       : { "path" : "DC=sevenkingdoms,DC=local"}
            },
```

#### multi_domain_groups_member (optional)
- Add a user from another domain into a group (must be a domainlocal group)

- Example on sevenkingdoms.local :

```
"domains" : {
    "sevenkingdoms.local" : {
            ...
            "groups" : {
                ...
                "domainlocal" : {
                    "AcrossTheSea" : {
                        "path" : "CN=Users,DC=North,DC=sevenkingdoms,DC=local"
                    }
                }
            },
            "multi_domain_groups_member" : {
                "AcrossTheSea" : [
                    "essos.local\\daenerys.targaryen"
                ]
            },
```

#### acls (optional)
- To create ace relations in your active directory

- Example on sevenkingdoms.local
```
"domains" : {
    "sevenkingdoms.local" : {
        ...
        "acls" : {
            "GenericAll_khal_viserys" : {"for": "khal.drogo", "to": "viserys.targaryen", "right": "GenericAll", "inheritance": "None"},
            "GenericAll_spy_jorah" : {"for": "Spys", "to": "jorah.mormont", "right": "GenericAll", "inheritance": "None"},
            "GenericAll_khal_esc4" : {"for": "khal.drogo", "to": "CN=ESC4,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=essos,DC=local", "right": "GenericAll", "inheritance": "None"},
            "WriteProperty_petyer_domadmin" : {"for": "viserys.targaryen", "to": "jorah.mormont", "right": "WriteProperty", "inheritance": "All"},
            "GenericWrite_DragonsFriends_braavos" : {"for": "DragonsFriends", "to": "braavoos$", "right": "GenericWrite", "inheritance": "None"}
        },
```

- acl are in the following format : 
  - for : the user concerned (user or group name)
  - to  : the user or group or CN target (where the ace will be applied)
  - right : the right to apply on this list :
    - AccessSystemSecurity
    - CreateChild
    - Delete
    - DeleteChild
    - DeleteTree
    - ExtendedRight
    - GenericAll
    - GenericExecute
    - GenericRead
    - GenericWrite
    - ListChildren
    - ListObject
    - ReadControl
    - ReadProperty
    - Self
    - Synchronize
    - WriteDacl
    - WriteOwner
    - WriteProperty
  - right can also be extended right, the extended right allowed are:
    - Ext-User-Force-Change-Password
    - Ext-Write-Self-Membership
    - Ext-Self-Self-Membership
  - inheritance: enable inheritance (All or None)


- To add anonymous rpc just add on the dc (this will allow anonymous user listing ):

```
"acls" : {
    "anonymous_rpc" : {"for": "NT AUTHORITY\\ANONYMOUS LOGON", "to": "DC=North,DC=sevenkingdoms,DC=local", "right": "ReadProperty", "inheritance": "All"},
    "anonymous_rpc2" : {"for": "NT AUTHORITY\\ANONYMOUS LOGON", "to": "DC=North,DC=sevenkingdoms,DC=local", "right": "GenericExecute", "inheritance": "All"}
},
```

#### laps_path and laps_readers (optional)

- To add laps just add laps_path on your domain with the name of the OU to create.
- all hosts with use_laps : true will be moved to that OU and laps will be applied
- laps_readers list all the users and group allow to read the laps password

```
"domains" : {
    "north.sevenkingdoms.local" : {
        ...
        "laps_path": "OU=Laps,DC=north,DC=sevenkingdoms,DC=local",
        ...
        "laps_readers": [
                "jorah.mormont",
                "Spys"
            ],
        ...
    }
}
```

#### trust (for trusts role)

- In case of external trust trust key must be setup in each domains
```
    "domains" : {
        "sevenkingdoms.local" : {
            ...
            "trust" : "essos.local",
            ...
        },
        "essos.local" : {
            ...
            "trust" : "sevenkingdoms.local",
```

#### ca_server (for adcs_customtemplates role)
- This param is use to precise the host to use on the template creation, this is mandatory if [adcs_customtemplates] role is used

```
   "domains" : {
        "essos.local" : {
            ...
            "ca_server": "Braavos",
```