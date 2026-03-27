# Sysmon extension

- Extension Name: sysmon
- Description: Deploy Sysmon with olafhartong modular config to all Windows domain machines
- Machine name: none (agent-only extension)
- Compatible with labs: *

## What it does

- Installs **Sysmon64** on every Windows machine in the `domain` group
- Uses **[olafhartong's sysmon-modular config](https://github.com/olafhartong/sysmon-modular)** for comprehensive detection coverage
- Covers: process creation, network connections, file creation, registry events, DNS queries, pipe events, WMI events, and more
- If Sysmon is already installed, updates the config in-place

## No prerequisites

No new VM is provisioned. This extension is agent-only.

## Install

```
instance_id> install_extension sysmon
```

## Purple team value

Sysmon events complement Windows Security event logs and are essential for detecting:
- Lateral movement (PtH, PtT, WMI, PSExec)
- Credential dumping (LSASS access)
- Persistence (registry, scheduled tasks, WMI subscriptions)
- C2 beaconing (DNS, network connections)
- LOLBins and living-off-the-land techniques

Pairs well with the **elk** and **wazuh** extensions for log ingestion.

## Credits
- [olafhartong/sysmon-modular](https://github.com/olafhartong/sysmon-modular)
- Sysinternals Sysmon: https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
