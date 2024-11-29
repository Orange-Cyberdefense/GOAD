# wazuh

!!! success "Thanks!"
    Credits and huge thanks to [aleemladha](https://github.com/aleemladha) for the ansible role. [https://github.com/Orange-Cyberdefense/GOAD/pull/215](https://github.com/Orange-Cyberdefense/GOAD/pull/215)

- Extension name : `wazuh`
- Description : Add wazuh free EDR server and agent on all the domain computers + soc fortress rules (https://github.com/socfortress/Wazuh-Rules)
- Compatibility  : *
- Providers : virtualbox/azure/vmware/aws/ludus 
- Add a machine  : wazuh (ip_range.51)

!!! warning "impacts"
    add a wazuh machine and a wazuh agent on all windows machine"


## Prerequisites

- On ludus prepare template :
```
ludus templates add -d ubuntu-22.04-x64-server
ludus templates build
```

- A lab installed

## Installation

- select your instance
```
load <instance_id>
```

- install the exchange extension
```
install_extension wazuh
```
