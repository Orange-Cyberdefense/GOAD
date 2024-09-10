# Ansible Role: Exchange 2019 (Ludus)

An Ansible Role that installs [Microsoft Exchange Server 2019](https://learn.microsoft.com/en-us/exchange/exchange-server?view=exchserver-2019).

- Turns the VM into Microsoft Exchange Server
- Users are can Test various CVEs including ProxyShell and ProxyLogon in a safe environment

## Requirements

None.

## Ludus install the exchange ansible role

```
# Add the role to your ludus host
ludus ansible roles add aleemladha.ludus_exchange

```


## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    # This pulls the netbios_name out of the domain assigned to this machine in the ludus range config
    ludus_exchange_domain: "{{ (ludus | selectattr('vm_name', 'match', inventory_hostname))[0].domain.fqdn.split('.')[0] }}"
    # This pulls the vm_name of the primary-dc for the domain assigned to this machine in the ludus range config
    ludus_exchange_dc: "{{ (ludus | selectattr('domain', 'defined') | selectattr('domain.fqdn', 'match', ludus_exchange_domain) | selectattr('domain.role', 'match', 'primary-dc'))[0].hostname }}"
    # This pulls the hostname from the ludus config for this host
    ludus_exchange_host: "{{ (ludus | selectattr('vm_name', 'match', inventory_hostname))[0].hostname }}"
    ludus_exchange_domain_username: "{{ ludus_exchange_domain }}\\{{ defaults.ad_domain_admin }}"
    ludus_exchange_domain_password: "{{ defaults.ad_domain_admin_password }}"
    
## Dependencies

None.

## Example Ludus config.yml file to deploy the range for various Exchange Attacks


```yaml
ludus:
  - vm_name: "{{ range_id }}-EXC-DC01"
    hostname: "{{ range_id }}-DC01"
    template: win2019-server-x64-template
    vlan: 20
    ip_last_octet: 2
    ram_gb: 8
    cpus: 4
    windows:
      sysprep: true
    domain:
      fqdn: ludus.domain
      role: primary-dc
    roles:
      - aleemladha.ludus_exchange
```

## Ludus setup

```

# Get your config into a file so you can assign to a VM
ludus range config get > config.yml

# Edit config to add the role to the VMs you wish to make an wazuh siem server
ludus range config set -f config.yml

# Deploy the range and access the kali machine to start attacking 
ludus range deploy


```

## License

GPLv3

## Author Information

This role was created in 2024 by [Aleem ladha](https://twitter.com/LadhaAleem).
