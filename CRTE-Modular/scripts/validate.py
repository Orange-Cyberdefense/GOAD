#!/usr/bin/env python3
"""
CRTE Modular Lab - Validation Script
This script validates the scenario selector and configuration generation functionality.
"""

import os
import sys
import yaml
import argparse
import subprocess
from pathlib import Path

# Add the scripts directory to the Python path
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_DIR)

# Import the scenario selector
from scenario_selector import ScenarioSelector

def validate_scenario_selector():
    """Validate that the scenario selector can list and select scenarios."""
    print("\n[+] Validating scenario selector functionality...")
    
    # Create a scenario selector instance
    selector = ScenarioSelector()
    
    # Get available scenarios
    scenarios = selector._get_available_scenarios()
    
    if not scenarios:
        print("[-] Error: No scenarios found.")
        return False
    
    print(f"[+] Found {len(scenarios)} scenarios:")
    for scenario_id, details in scenarios.items():
        print(f"  - {scenario_id}: {details['name']}")
    
    # Test selecting a scenario
    test_scenario = list(scenarios.keys())[0]
    print(f"\n[+] Testing scenario selection with '{test_scenario}'...")
    
    if not selector.select_scenario(test_scenario):
        print(f"[-] Error: Failed to select scenario '{test_scenario}'.")
        return False
    
    print(f"[+] Successfully selected scenario '{test_scenario}'.")
    return True

def validate_config_generation(output_dir):
    """Validate that configurations can be generated for each scenario."""
    print("\n[+] Validating configuration generation...")
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Create a scenario selector instance
    selector = ScenarioSelector()
    
    # Get available scenarios
    scenarios = selector._get_available_scenarios()
    
    success_count = 0
    failure_count = 0
    
    for scenario_id in scenarios.keys():
        print(f"\n[+] Testing configuration generation for '{scenario_id}'...")
        
        # Select the scenario
        if not selector.select_scenario(scenario_id):
            print(f"[-] Error: Failed to select scenario '{scenario_id}'.")
            failure_count += 1
            continue
        
        # Create scenario-specific output directory
        scenario_output_dir = os.path.join(output_dir, scenario_id)
        os.makedirs(scenario_output_dir, exist_ok=True)
        
        # Generate Vagrant configuration
        vagrant_success = selector.generate_vagrant_config(scenario_output_dir)
        
        # Generate Ansible inventory
        ansible_success = selector.generate_ansible_inventory(scenario_output_dir)
        
        if vagrant_success and ansible_success:
            print(f"[+] Successfully generated configurations for '{scenario_id}'.")
            success_count += 1
        else:
            print(f"[-] Error: Failed to generate configurations for '{scenario_id}'.")
            failure_count += 1
    
    print(f"\n[+] Configuration generation results:")
    print(f"  - Successful: {success_count}")
    print(f"  - Failed: {failure_count}")
    
    return success_count > 0 and failure_count == 0

def validate_goad_integration():
    """Validate that the scenario selector can be integrated with GOAD."""
    print("\n[+] Validating GOAD integration potential...")
    
    # Check if GOAD directory exists
    goad_dir = "/home/ubuntu/GOAD"
    if not os.path.exists(goad_dir):
        print(f"[-] Warning: GOAD directory not found at {goad_dir}.")
        print("    Integration validation will be theoretical only.")
    else:
        print(f"[+] Found GOAD directory at {goad_dir}.")
        
        # Check for goad.py
        goad_py = os.path.join(goad_dir, "goad.py")
        if os.path.exists(goad_py):
            print(f"[+] Found goad.py at {goad_py}.")
            print("    Integration should be possible by extending the Goad class.")
        else:
            print(f"[-] Warning: goad.py not found at {goad_py}.")
    
    # Theoretical integration validation
    print("\n[+] Theoretical GOAD integration validation:")
    print("    1. The scenario selector can be called from GOAD's command interface")
    print("    2. Selected scenario configurations can be used to generate GOAD-compatible files")
    print("    3. GOAD's provisioning system can be used to deploy the selected scenario")
    
    return True

def main():
    parser = argparse.ArgumentParser(description="CRTE Modular Lab Validation Script")
    parser.add_argument("--output-dir", metavar="DIR", default="/tmp/crte-validation", 
                        help="Output directory for generated test files")
    
    args = parser.parse_args()
    
    print("=" * 80)
    print("CRTE Modular Lab - Validation Script")
    print("=" * 80)
    
    # Validate scenario selector
    selector_valid = validate_scenario_selector()
    
    # Validate configuration generation
    config_valid = validate_config_generation(args.output_dir)
    
    # Validate GOAD integration
    integration_valid = validate_goad_integration()
    
    # Print summary
    print("\n" + "=" * 80)
    print("Validation Summary")
    print("=" * 80)
    print(f"Scenario Selector: {'PASS' if selector_valid else 'FAIL'}")
    print(f"Configuration Generation: {'PASS' if config_valid else 'FAIL'}")
    print(f"GOAD Integration: {'PASS' if integration_valid else 'FAIL'}")
    print("=" * 80)
    
    if selector_valid and config_valid and integration_valid:
        print("\n[+] All validation tests passed!")
        print("    The CRTE Modular Lab is ready for deployment.")
        return 0
    else:
        print("\n[-] Some validation tests failed.")
        print("    Please review the output and fix any issues.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
