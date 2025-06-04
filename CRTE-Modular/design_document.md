# CRTE Modular Lab Design Document

## Overview

This document outlines the design for a modular, scenario-based CRTE lab environment that integrates with the GOAD framework. The design focuses on resource efficiency, allowing users to deploy only the VMs needed for specific attack scenarios.

## Design Goals

1. **Modularity**: Enable deployment of specific attack scenarios without requiring the entire lab
2. **Resource Efficiency**: Minimize RAM and CPU requirements by deploying only necessary VMs
3. **GOAD Integration**: Seamlessly integrate with the GOAD workflow and shell script
4. **Extensibility**: Support easy addition of new scenarios in the future
5. **Comprehensive Coverage**: Include all attack techniques required for CRTE certification

## Architecture

### Directory Structure

```
CRTE-Modular/
├── README.md                 # Overview and usage instructions
├── base/                     # Base configuration files
│   ├── base_config.yml       # Shared configuration settings
│   ├── vm_templates.yml      # VM template definitions
│   └── network_config.yml    # Network configuration
├── scenarios/                # Scenario-specific configurations
│   ├── kerberoasting.yml
│   ├── asrep_roasting.yml
│   ├── unconstrained_delegation.yml
│   ├── constrained_delegation.yml
│   ├── rbcd.yml
│   ├── acl_abuse.yml
│   ├── domain_trusts.yml
│   ├── forest_trusts.yml
│   ├── sql_links.yml
│   ├── exchange_attacks.yml
│   └── azure_ad_connect.yml
└── scripts/                  # Helper scripts
    ├── scenario_selector.py  # Script to select and deploy scenarios
    ├── goad_integration.py   # GOAD integration utilities
    └── validation.py         # Validation utilities
```

### Scenario Configuration Format

Each scenario configuration file follows a standardized YAML format:

```yaml
scenario_name: "Scenario Name"
description: "Detailed description of the scenario"
estimated_ram: "Estimated RAM required"

required_vms:
  - name: "vm-name"
    role: "VM role description"
    ram: RAM in MB
    cpus: Number of CPUs
    ip: "IP address"
    os: "windows/linux"
    box: "Vagrant box name"
    box_version: "Box version"

attack_path:
  - "Step 1 description"
  - "Step 2 description"
  - "Step 3 description"

references:
  - "Reference to CRTE Notion material"
```

### GOAD Integration

The modular lab will integrate with GOAD through:

1. **Scenario Selection Command**: Add a `set_scenario` command to the GOAD shell interface
2. **Lab Type Extension**: Extend the CRTE lab type to support scenario-based deployment
3. **Configuration Generation**: Generate Vagrant and Ansible configurations based on selected scenario

## Scenario Mapping

Based on the CRTE requirements, the following scenarios will be implemented:

### Local Privilege Escalation
- **Scenario**: local_privesc
- **VMs**: techcorp-dc, us-web, student
- **Techniques**: Misconfigured services, vulnerable applications, token manipulation

### Kerberos Attacks
- **Scenario**: kerberoasting (implemented)
- **VMs**: techcorp-dc, us-dc, us-web, student
- **Techniques**: Kerberoasting service accounts

- **Scenario**: asrep_roasting (implemented)
- **VMs**: techcorp-dc, us-dc, student
- **Techniques**: AS-REP Roasting for accounts without preauthentication

### Delegation Attacks
- **Scenario**: unconstrained_delegation (implemented)
- **VMs**: techcorp-dc, us-dc, us-exchange, student
- **Techniques**: Exploiting unconstrained delegation

- **Scenario**: constrained_delegation (implemented)
- **VMs**: techcorp-dc, us-dc, us-web, us-mssql, student
- **Techniques**: Exploiting constrained delegation

- **Scenario**: rbcd
- **VMs**: techcorp-dc, us-dc, us-web, student
- **Techniques**: Exploiting resource-based constrained delegation

### ACL Attacks
- **Scenario**: acl_abuse
- **VMs**: techcorp-dc, us-dc, us-mgmt, student
- **Techniques**: Exploiting misconfigured ACLs, WriteDACL, WriteOwner

### Trust Attacks
- **Scenario**: domain_trusts
- **VMs**: techcorp-dc, us-dc, student
- **Techniques**: Exploiting parent-child domain trust relationships

- **Scenario**: forest_trusts
- **VMs**: techcorp-dc, us-dc, bastion-dc, production-dc, student
- **Techniques**: Exploiting forest trust relationships, SID history abuse

### Service Attacks
- **Scenario**: sql_links
- **VMs**: techcorp-dc, us-dc, us-mssql, db-sqlprod, db-sqlsrv, student
- **Techniques**: Exploiting SQL server link configurations

- **Scenario**: exchange_attacks
- **VMs**: techcorp-dc, us-dc, us-exchange, student
- **Techniques**: Exploiting Exchange server vulnerabilities

- **Scenario**: azure_ad_connect
- **VMs**: techcorp-dc, us-dc, us-adconnect, student
- **Techniques**: Exploiting Azure AD Connect for credential extraction

## Resource Optimization

To ensure efficient resource usage, the design includes:

1. **Minimal VM Configurations**: Each scenario includes only the VMs necessary for that specific attack path
2. **Shared Base VMs**: Common VMs like domain controllers are reused across scenarios
3. **Resource Scaling**: RAM and CPU allocations are adjusted based on VM role and requirements
4. **Optimized Box Selection**: Using lightweight boxes where possible

## Implementation Plan

1. **Complete Base Configuration**: Finalize base configuration files with shared settings
2. **Implement Missing Scenarios**: Create configuration files for all required scenarios
3. **Develop Scenario Selector**: Implement the scenario selection mechanism
4. **Integrate with GOAD**: Modify GOAD shell script to support scenario selection
5. **Create Documentation**: Update README and usage instructions
6. **Validate Implementation**: Test each scenario for functionality and resource usage

## Usage Workflow

1. User starts GOAD with the CRTE lab option:
   ```bash
   ./goad.sh -p vmware -l CRTE
   ```

2. User selects a specific scenario:
   ```
   CRTE/vmware/local/192.168.56.X > set_scenario kerberoasting
   ```

3. User initiates installation:
   ```
   CRTE/vmware/local/192.168.56.X > install
   ```

4. The system deploys only the VMs required for the selected scenario

5. User practices the specific attack technique using their CRTE Notion material

## Conclusion

This modular, scenario-based design for the CRTE lab environment provides an efficient and flexible approach to practicing CRTE attack techniques. By deploying only the VMs needed for specific scenarios, users can make the most of their available system resources while still gaining hands-on experience with all required CRTE attack paths.
