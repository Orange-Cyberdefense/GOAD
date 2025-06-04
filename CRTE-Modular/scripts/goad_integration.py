# CRTE Modular Lab - GOAD Integration Script

"""
This script extends the GOAD shell script to support scenario-based deployment for CRTE lab.
It should be placed in the GOAD directory and called from the modified goad.sh script.
"""

import os
import sys
import yaml
import argparse
from pathlib import Path

# Base paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CRTE_DIR = os.path.join(SCRIPT_DIR, "ad", "CRTE-Modular")
SCENARIOS_DIR = os.path.join(CRTE_DIR, "scenarios")

def get_available_scenarios():
    """Get a list of available scenarios from the scenarios directory."""
    scenarios = {}
    
    if not os.path.exists(SCENARIOS_DIR):
        print(f"Error: Scenarios directory not found at {SCENARIOS_DIR}")
        return scenarios
        
    for file in os.listdir(SCENARIOS_DIR):
        if file.endswith('.yml'):
            scenario_path = os.path.join(SCENARIOS_DIR, file)
            try:
                with open(scenario_path, 'r') as f:
                    scenario_data = yaml.safe_load(f)
                    scenario_name = scenario_data.get('scenario_name', os.path.splitext(file)[0])
                    scenarios[os.path.splitext(file)[0]] = {
                        'name': scenario_name,
                        'description': scenario_data.get('description', ''),
                        'estimated_ram': scenario_data.get('estimated_ram', 'Unknown'),
                        'path': scenario_path
                    }
            except Exception as e:
                print(f"Error loading scenario {file}: {str(e)}")
                
    return scenarios

def list_scenarios():
    """List all available scenarios with descriptions."""
    scenarios = get_available_scenarios()
    
    if not scenarios:
        print("No scenarios available.")
        return
        
    print("\nAvailable CRTE Attack Scenarios:")
    print("=" * 80)
    print(f"{'ID':<20} {'Name':<30} {'Est. RAM':<10} {'Description'}")
    print("-" * 80)
    
    for scenario_id, details in scenarios.items():
        print(f"{scenario_id:<20} {details['name']:<30} {details['estimated_ram']:<10} {details['description']}")
    
    print("=" * 80)

def select_scenario(scenario_id):
    """Select a specific scenario by ID."""
    scenarios = get_available_scenarios()
    
    if scenario_id not in scenarios:
        print(f"Error: Scenario '{scenario_id}' not found.")
        print("Available scenarios:")
        for sid in scenarios.keys():
            print(f"  - {sid}")
        return None
        
    scenario = scenarios[scenario_id]
    print(f"Selected scenario: {scenario['name']}")
    print(f"Description: {scenario['description']}")
    print(f"Estimated RAM required: {scenario['estimated_ram']}")
    
    try:
        with open(scenario['path'], 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading scenario configuration: {str(e)}")
        return None

def generate_vagrant_config(scenario_config, output_dir, ip_range="192.168.56"):
    """Generate Vagrant configuration for the selected scenario."""
    if not scenario_config:
        print("Error: No scenario configuration provided.")
        return False
        
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate Vagrantfile
    vagrantfile_path = os.path.join(output_dir, "Vagrantfile")
    
    try:
        with open(vagrantfile_path, 'w') as f:
            f.write("# -*- mode: ruby -*-\n")
            f.write("# vi: set ft=ruby :\n\n")
            f.write(f"# CRTE Modular Lab - {scenario_config['scenario_name']} Scenario\n")
            f.write("# Auto-generated Vagrantfile - Do not modify directly\n\n")
            
            f.write("Vagrant.configure(\"2\") do |config|\n")
            
            # Add VM configurations
            for vm in scenario_config.get('required_vms', []):
                vm_name = vm['name']
                f.write(f"  config.vm.define \"{vm_name}\" do |{vm_name.replace('-', '_')}|\n")
                f.write(f"    {vm_name.replace('-', '_')}.vm.box = \"{vm['box']}\"\n")
                f.write(f"    {vm_name.replace('-', '_')}.vm.box_version = \"{vm['box_version']}\"\n")
                
                # Replace IP range placeholder
                vm_ip = vm['ip'].replace('{{ip_range}}', ip_range)
                f.write(f"    {vm_name.replace('-', '_')}.vm.network \"private_network\", ip: \"{vm_ip}\"\n")
                
                # VM provider settings
                f.write(f"    {vm_name.replace('-', '_')}.vm.provider \"vmware_desktop\" do |v|\n")
                f.write(f"      v.memory = {vm['ram']}\n")
                f.write(f"      v.cpus = {vm['cpus']}\n")
                f.write(f"      v.gui = true\n")
                f.write("    end\n")
                
                # VM provider settings for VirtualBox
                f.write(f"    {vm_name.replace('-', '_')}.vm.provider \"virtualbox\" do |v|\n")
                f.write(f"      v.memory = {vm['ram']}\n")
                f.write(f"      v.cpus = {vm['cpus']}\n")
                f.write(f"      v.gui = true\n")
                f.write("    end\n")
                
                f.write("  end\n\n")
            
            f.write("end\n")
            
        print(f"Generated Vagrantfile at {vagrantfile_path}")
        return True
        
    except Exception as e:
        print(f"Error generating Vagrant configuration: {str(e)}")
        return False

def generate_ansible_inventory(scenario_config, output_dir, ip_range="192.168.56"):
    """Generate Ansible inventory for the selected scenario."""
    if not scenario_config:
        print("Error: No scenario configuration provided.")
        return False
        
    # Create output directory if it doesn't exist
    inventory_dir = os.path.join(output_dir, "inventory")
    os.makedirs(inventory_dir, exist_ok=True)
    
    # Generate inventory file
    inventory_path = os.path.join(inventory_dir, "hosts.yml")
    
    try:
        inventory = {
            'all': {
                'children': {
                    'windows': {
                        'children': {
                            'domain_controllers': {
                                'hosts': {}
                            },
                            'servers': {
                                'hosts': {}
                            }
                        }
                    },
                    'linux': {
                        'hosts': {}
                    }
                }
            }
        }
        
        # Add VMs to inventory
        for vm in scenario_config.get('required_vms', []):
            vm_name = vm['name']
            vm_ip = vm['ip'].replace('{{ip_range}}', ip_range)
            
            if vm['os'].lower() == 'windows':
                if 'dc' in vm_name.lower():
                    # Add to domain controllers group
                    inventory['all']['children']['windows']['children']['domain_controllers']['hosts'][vm_name] = {
                        'ansible_host': vm_ip
                    }
                else:
                    # Add to servers group
                    inventory['all']['children']['windows']['children']['servers']['hosts'][vm_name] = {
                        'ansible_host': vm_ip
                    }
            else:
                # Add to linux group
                inventory['all']['children']['linux']['hosts'][vm_name] = {
                    'ansible_host': vm_ip
                }
        
        # Write inventory file
        with open(inventory_path, 'w') as f:
            yaml.dump(inventory, f, default_flow_style=False)
            
        print(f"Generated Ansible inventory at {inventory_path}")
        return True
        
    except Exception as e:
        print(f"Error generating Ansible inventory: {str(e)}")
        return False

def main():
    parser = argparse.ArgumentParser(description="CRTE Modular Lab GOAD Integration")
    parser.add_argument("--list-scenarios", action="store_true", help="List available scenarios")
    parser.add_argument("--select-scenario", metavar="SCENARIO_ID", help="Select a specific scenario")
    parser.add_argument("--output-dir", metavar="DIR", default="./output", help="Output directory for generated files")
    parser.add_argument("--ip-range", metavar="RANGE", default="192.168.56", help="IP range for VM network")
    
    args = parser.parse_args()
    
    if args.list_scenarios:
        list_scenarios()
        return
        
    if args.select_scenario:
        scenario_config = select_scenario(args.select_scenario)
        if scenario_config:
            generate_vagrant_config(scenario_config, args.output_dir, args.ip_range)
            generate_ansible_inventory(scenario_config, args.output_dir, args.ip_range)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
