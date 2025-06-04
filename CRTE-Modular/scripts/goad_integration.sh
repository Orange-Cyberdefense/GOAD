#!/bin/bash
# CRTE Modular Lab - GOAD Shell Integration Script

# This script adds the set_scenario command to the GOAD shell interface
# It should be sourced from the modified goad.sh script

# Function to list available scenarios
function list_scenarios() {
    python3 $CRTE_MODULAR_DIR/scripts/scenario_selector.py --list
}

# Function to select a scenario
function select_scenario() {
    if [ -z "$1" ]; then
        echo "Error: No scenario specified."
        echo "Usage: set_scenario <scenario_id>"
        list_scenarios
        return 1
    fi
    
    # Set the current scenario
    export CRTE_SCENARIO=$1
    
    # Use the scenario selector to validate the selection
    python3 $CRTE_MODULAR_DIR/scripts/scenario_selector.py --select $CRTE_SCENARIO
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to select scenario '$CRTE_SCENARIO'."
        unset CRTE_SCENARIO
        return 1
    fi
    
    echo "Scenario '$CRTE_SCENARIO' selected successfully."
    return 0
}

# Function to generate configuration files for the selected scenario
function generate_scenario_config() {
    if [ -z "$CRTE_SCENARIO" ]; then
        echo "Error: No scenario selected."
        echo "Use 'set_scenario <scenario_id>' to select a scenario."
        return 1
    fi
    
    # Get the IP range
    local ip_range=${1:-"192.168.56"}
    
    # Generate configuration files
    python3 $CRTE_MODULAR_DIR/scripts/scenario_selector.py --select $CRTE_SCENARIO --generate --output-dir $CRTE_OUTPUT_DIR --ip-range $ip_range
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate configuration files for scenario '$CRTE_SCENARIO'."
        return 1
    fi
    
    echo "Configuration files generated successfully for scenario '$CRTE_SCENARIO'."
    return 0
}

# Add the set_scenario command to the GOAD shell interface
function set_scenario() {
    select_scenario $1
}

# Initialize CRTE Modular Lab environment variables
export CRTE_MODULAR_DIR="/home/ubuntu/CRTE-Modular"
export CRTE_OUTPUT_DIR="/tmp/crte-output"
