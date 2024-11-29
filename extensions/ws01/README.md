# WS01 extension (Workstation 01)

- Extension Name: ws01
- Description: Add a Windows 10 workstation to the lab GOAD or GOAD Light in the domain sevenkingdoms.local
- Machine name : {{lab_name}}-WS01
- Compatible with labs :
  - GOAD
  - GOAD-Light

- Lab infos:
  - hostname: casterlyrock 
  - Users:
    - Administrators :
      - tywin.lannister
      - jaime.lannister
    - RDP Users:
      - Lannister group

- Features :
  - run_as_ppl
  - powershell restricted
  - asr rules :
    - block lsass stealing
    - block PSExec and WMI

- Providers:
  - aws doesn't provide windows10 ami. you can still install ws01 but a windows server 2019 will be used instead

## prerequisites

On ludus prepare template :
```
ludus templates add -d win10-21h1-x64-enterprise
ludus templates build
```

## Install

```
instance_id> install_extension ws01
```

## Uninstall

- Not implemented yet

## credits:
- asr rules implementation : https://github.com/zuesdevil (https://github.com/Orange-Cyberdefense/GOAD/pull/172)
