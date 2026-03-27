# Zeek extension

- Extension Name: zeek
- Description: Add a Zeek network security monitor to the lab
- Machine name: `{{lab_name}}-ZEEK`
- IP: `{{ip_range}}.53`
- Compatible with labs: *

## What it does

- Spins up an **Ubuntu 22.04** VM running **Zeek** (formerly Bro)
- Passively monitors all lab network traffic on `eth1` (the host-only/lab interface)
- Enables **JSON log output** for easy ingestion into ELK, Splunk, or other SIEMs
- Loads AD-relevant protocol analyzers: SMB, DCE-RPC, Kerberos, RDP, LDAP
- Sets up `zeekctl cron` every 5 minutes for log rotation and health checks

## Prerequisites

On ludus prepare template:
```
ludus templates add -d ubuntu-22.04-x64-server
ludus templates build
```

## Install

```
instance_id> install_extension zeek
```

## Useful commands (on the Zeek VM)

```bash
# Check status
zeekctl status

# View live DNS logs
tail -f /opt/zeek/logs/current/dns.log | jq .

# View Kerberos traffic
tail -f /opt/zeek/logs/current/kerberos.log | jq .

# View SMB activity
tail -f /opt/zeek/logs/current/smb_files.log | jq .

# View DCE-RPC calls (lateral movement)
tail -f /opt/zeek/logs/current/dce_rpc.log | jq .
```

## Purple team value

Zeek provides **network-layer** visibility that host-based agents (Sysmon, Wazuh) cannot see:
- Kerberoasting / AS-REP roasting (unusual Kerberos ticket requests)
- Pass-the-Hash / lateral movement (SMB/DCE-RPC patterns)
- LDAP enumeration (large LDAP queries)
- DNS-based C2 / exfiltration
- Unusual authentication patterns across the domain

Pairs well with **sysmon** (host) + **elk** or **wazuh** (SIEM) for full coverage.
