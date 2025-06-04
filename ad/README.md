# CRTE Modular Lab

This is a modular implementation of the CRTE lab for GOAD, designed to allow scenario-based deployment of only the VMs needed for specific attack paths. This approach optimizes resource usage and makes the lab practical to run on systems with limited RAM.

## Overview

The CRTE Modular Lab extends the GOAD framework with:

1. Scenario-specific configurations for each CRTE attack technique
2. A scenario selector integrated into the GOAD shell script
3. Optimized VM configurations for efficient resource usage

## Scenarios

Each scenario is designed to provide the minimal infrastructure needed to practice specific CRTE attack techniques:

1. **Kerberoasting** - Practice extracting and cracking service account hashes
2. **AS-REP Roasting** - Exploit accounts with "Do not require Kerberos preauthentication"
3. **Unconstrained Delegation** - Exploit servers with unconstrained delegation enabled
4. **Constrained Delegation** - Exploit servers with constrained delegation
5. **Resource-Based Constrained Delegation** - Exploit RBCD misconfigurations
6. **ACL Abuse** - Exploit misconfigured access control lists
7. **Domain Trusts** - Exploit trust relationships between domains
8. **Forest Trusts** - Exploit trust relationships between forests
9. **SQL Server Links** - Exploit linked SQL servers for lateral movement
10. **Exchange Attacks** - Exploit Exchange server vulnerabilities
11. **Azure AD Connect** - Exploit Azure AD Connect for credential extraction

## Resource Requirements

Each scenario has different resource requirements:

- **Minimal Scenarios**: 8-10GB RAM
- **Medium Scenarios**: 12-16GB RAM
- **Complex Scenarios**: 18-24GB RAM

## Usage

Select a scenario using the GOAD shell script:
```
./goad.sh -p vmware -l CRTE
> set_scenario kerberoasting
> install
```

## Directory Structure

- `/scenarios` - Contains scenario-specific configurations
- `/base` - Contains base VM configurations and shared resources
- `/scripts` - Contains helper scripts for scenario management
