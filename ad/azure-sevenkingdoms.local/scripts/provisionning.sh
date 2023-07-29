#!/bin/bash

RESTART_COUNT=0
MAX_RETRY=3

ANSIBLE_COMMAND="ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory"

function run_ansible {
    # Check if the maximum number of retries is reached, then exit with an error code
    if [ $RESTART_COUNT -eq $MAX_RETRY ]; then
        echo "[!] $MAX_RETRY restarts occurred, exiting..."
        exit 2
    fi

    echo "[+] Restart counter: $RESTART_COUNT"
    let "RESTART_COUNT += 1"

    echo "[+] Running command: $ANSIBLE_COMMAND $1"

    # Run the command with a timeout of 20 minutes to avoid failure when ansible is stuck
    timeout 20m $ANSIBLE_COMMAND $1
    exit_code=$(echo $?)

    if [ $exit_code -eq 4 ]; then # ansible result code 4 = RUN_UNREACHABLE_HOSTS
        echo "[!] Error while running: $ANSIBLE_COMMAND $1"
        echo "[!] Some hosts were unreachable, we are going to retry"
        run_ansible $1

    elif [ $exit_code -eq 124 ]; then # Command has timed out, relaunch the ansible playbook
        echo "[!] Error while running: $ANSIBLE_COMMAND $1"
        echo "[!] Command has reached the timeout limit of 20 minutes, we are going to retry"
        run_ansible $1

    elif [ $exit_code -eq 0 ]; then # ansible result code 0 = RUN_OK
        echo "[+] Command successfully executed"
        RESTART_COUNT=0 # Reset the counter for the next playbook
        return 0

    else
        echo "[!] Fatal error from ansible with exit code: $exit_code"
        echo "[!] We are going to retry"
        run_ansible $1
    fi
}

cd GOAD/ansible
source .venv/bin/activate

# We run all the recipes separately to minimize faillure
echo "[+] Running all the playbook to setup the lab"
run_ansible build.yml

run_ansible "ad-servers.yml --tags data,prepare_servers,dc_main_domains"

# Wait after the child domain creation before adding servers
run_ansible "ad-servers.yml --tags data,child_domain"
echo "[+] Waiting 5 minutes for the child domain to be ready"
sleep 5m

run_ansible "ad-servers.yml --tags data,server"

run_ansible ad-trusts.yml

run_ansible ad-data.yml

# LAPS seems to break authentication on srv03 on Azure AD, so we skip it
# run_ansible laps.yml

run_ansible ad-relations.yml

run_ansible adcs.yml

run_ansible ad-acl.yml

run_ansible servers.yml

run_ansible security.yml

run_ansible vulnerabilities.yml

echo "[+] GOAD is successfully setup !"
