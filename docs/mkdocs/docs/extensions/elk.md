# elk

- Extension name : `elk`
- Compatibility  : `*`
- Providers : virtualbox/azure/vmware/aws/cloudru/ludus
- Add a machine  : elk  (ip_range.50)

- Kibana is configured on http://{{ip_range}}.50:5601 to follow the lab events
- Infos : log encyclopedia : https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/
- Install filebeat agent on domain computer machines

## prerequisites

- You need `sshpass` for the elk installation
```bash
sudo apt install sshpass
```

!!! warning "Cloud download mirrors"
    If Elastic downloads fail with `403` or `404` on CloudRU, apply the ELK part of the patch from [CloudRU manual download patches](../providers/cloudru.md#manual-download-patches).

- On ludus prepare template :
```
ludus templates add -d ubuntu-22.04-x64-server
ludus templates build
```

## Install

- select your instance
```
load <instance_id>
```

- install the elk extension
```
install_extension elk
```
