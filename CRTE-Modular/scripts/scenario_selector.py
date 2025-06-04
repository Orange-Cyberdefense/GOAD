#!/usr/bin/env python3
"""
CRTE Modular Lab - Scenario Selector
This script provides functionality to select and configure specific CRTE attack scenarios.
"""

import os
import sys
import yaml
import argparse
import shutil
from pathlib import Path

# Base paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SCRIPT_DIR)
SCENARIOS_DIR = os.path.join(BASE_DIR, "scenarios")
BASE_CONFIG_DIR = os.path.join(BASE_DIR, "base")

class ScenarioSelector:
    def __init__(self, goad_dir=None):
        """Initialize the scenario selector with optional GOAD directory path."""
        self.goad_dir = goad_dir
        self.available_scenarios = self._get_available_scenarios()
        self.current_scenario = None
        
    def _get_available_scenarios(self):
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
    
    def list_scenarios(self):
        """List all available scenarios with descriptions."""
        if not self.available_scenarios:
            print("No scenarios available.")
            return
            
        print("\nAvailable CRTE Attack Scenarios:")
        print("=" * 80)
        print(f"{'ID':<20} {'Name':<30} {'Est. RAM':<10} {'Description'}")
        print("-" * 80)
        
        for scenario_id, details in self.available_scenarios.items():
            print(f"{scenario_id:<20} {details['name']:<30} {details['estimated_ram']:<10} {details['description']}")
        
        print("=" * 80)
    
    def select_scenario(self, scenario_id):
        """Select a specific scenario by ID."""
        if scenario_id not in self.available_scenarios:
            print(f"Error: Scenario '{scenario_id}' not found.")
            print("Available scenarios:")
            for sid in self.available_scenarios.keys():
                print(f"  - {sid}")
            return False
            
        self.current_scenario = scenario_id
        scenario = self.available_scenarios[scenario_id]
        print(f"Selected scenario: {scenario['name']}")
        print(f"Description: {scenario['description']}")
        print(f"Estimated RAM required: {scenario['estimated_ram']}")
        return True
    
    def get_current_scenario_config(self):
        """Get the configuration for the currently selected scenario."""
        if not self.current_scenario:
            print("Error: No scenario selected.")
            return None
            
        scenario_path = self.available_scenarios[self.current_scenario]['path']
        try:
            with open(scenario_path, 'r') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"Error loading scenario configuration: {str(e)}")
            return None
    
    def generate_vagrant_config(self, output_dir, ip_range="192.168.56"):
        """Generate Vagrant configuration for the selected scenario."""
        if not self.current_scenario:
            print("Error: No scenario selected.")
            return False
            
        scenario_config = self.get_current_scenario_config()
        if not scenario_config:
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
    
    def generate_ansible_inventory(self, output_dir, ip_range="192.168.56"):
        """Generate Ansible inventory for the selected scenario."""
        if not self.current_scenario:
            print("Error: No scenario selected.")
            return False
            
        scenario_config = self.get_current_scenario_config()
        if not scenario_config:
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
    parser = argparse.ArgumentParser(description="CRTE Modular Lab Scenario Selector")
    parser.add_argument("--list", action="store_true", help="List available scenarios")
    parser.add_argument("--select", metavar="SCENARIO_ID", help="Select a specific scenario")
    parser.add_argument("--generate", action="store_true", help="Generate configuration files for selected scenario")
    parser.add_argument("--output-dir", metavar="DIR", default="./output", help="Output directory for generated files")
    parser.add_argument("--ip-range", metavar="RANGE", default="192.168.56", help="IP range for VM network")
    
    args = parser.parse_args()
    
    selector = ScenarioSelector()
    
    if args.list:
        selector.list_scenarios()
        return
        
    if args.select:
        if not selector.select_scenario(args.select):
            return
            
    if args.generate:
        if not selector.current_scenario:
            print("Error: No scenario selected. Use --select SCENARIO_ID first.")
            return
            
        selector.generate_vagrant_config(args.output_dir, args.ip_range)
        selector.generate_ansible_inventory(args.output_dir, args.ip_range)

if __name__ == "__main__":
    main()
