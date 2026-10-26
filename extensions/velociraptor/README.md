# Velociraptor extension

- Extension Name: velociraptor
- Description: Add Velociraptor DFIR platform - server + agents on all Windows domain machines
- Machine name: `{{lab_name}}-VELO`
- IP: `{{ip_range}}.54`
- Compatible with labs: *

## What it does

- Spins up an **Ubuntu 22.04** VM running the **Velociraptor** server
- Generates server config and auto-repackages the Windows agent MSI with embedded certs
- Deploys the **Velociraptor agent** to every Windows machine in the `domain` group
- Exposes the **Velociraptor GUI** on port `8889`

## Prerequisites

On ludus prepare template:
```
ludus templates add -d ubuntu-22.04-x64-server
ludus templates build
```

## Install

```
instance_id> install_extension velociraptor
```

## Access

After installation, access the web UI at:
```
https://<ip_range>.54:8889
Username: admin
Password: Velo@GOAD2024!
```

> Note: The cert is self-signed — accept the browser warning.

## Useful VQL hunts for purple teaming

```sql
-- Find all processes with LSASS handles (credential dumping)
SELECT Pid, Name, CommandLine FROM pslist()
WHERE Name =~ "lsass"

-- Hunt for scheduled tasks (persistence)
SELECT * FROM Artifact.Windows.System.ScheduledTasks()

-- Find lateral movement via WMI
SELECT * FROM Artifact.Windows.EventLogs.EvtxHunter(
    EvtxGlob="**\\Security.evtx",
    IdFilter="4648"
)

-- Detect Kerberoasting (TGS requests for service accounts)
SELECT * FROM Artifact.Windows.EventLogs.EvtxHunter(
    EvtxGlob="**\\Security.evtx",
    IdFilter="4769"
)
WHERE TicketEncryptionType = "0x17"
```

## Purple team value

Velociraptor is a **live forensics and endpoint hunting** platform:
- **Incident response**: Live memory, process, registry, filesystem triage
- **Threat hunting**: VQL queries across the entire fleet simultaneously
- **Detection validation**: Confirm whether attacks were actually executed and what artifacts they left
- **Timeline reconstruction**: Correlate artifacts across multiple machines

Pairs well with **sysmon** (for enriched Windows events) and **zeek** (for network context).

## Credits
- https://github.com/Velocidex/velociraptor
- https://docs.velociraptor.app/
