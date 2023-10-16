#!/bin/bash

ERROR=$(tput setaf 1; echo -n "[!]"; tput sgr0)
OK=$(tput setaf 2; echo -n "[✓]"; tput sgr0)
INFO=$(tput setaf 3; echo -n "[-]"; tput sgr0)

RESTART_COUNT=0
MAX_RETRY=3

#ANSIBLE_COMMAND="ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory"
echo "[+] Current folder $(pwd)"
echo "[+] Ansible command : $ANSIBLE_COMMAND"

function run_ansible {
    # Check if the maximum number of retries is reached, then exit with an error code
    if [ $RESTART_COUNT -eq $MAX_RETRY ]; then
        echo "$ERROR $MAX_RETRY restarts occurred, exiting..."
        exit 2
    fi

    echo "[+] Restart counter: $RESTART_COUNT"
    let "RESTART_COUNT += 1"

    echo "$OK Running command: $ANSIBLE_COMMAND $1"

    # Run the command with a timeout of 20 minutes to avoid failure when ansible is stuck
    timeout 20m $ANSIBLE_COMMAND $1
    exit_code=$(echo $?)

    if [ $exit_code -eq 4 ]; then # ansible result code 4 = RUN_UNREACHABLE_HOSTS
        echo "$ERROR Error while running: $ANSIBLE_COMMAND $1"
        echo "$ERROR Some hosts were unreachable, we are going to retry"
        run_ansible $1

    elif [ $exit_code -eq 124 ]; then # Command has timed out, relaunch the ansible playbook
        echo "$ERROR Error while running: $ANSIBLE_COMMAND $1"
        echo "$ERROR Command has reached the timeout limit of 20 minutes, we are going to retry"
        run_ansible $1

    elif [ $exit_code -eq 0 ]; then # ansible result code 0 = RUN_OK
        echo "$OK Command successfully executed"
        RESTART_COUNT=0 # Reset the counter for the next playbook
        return 0

    else
        echo "$ERROR Fatal error from ansible with exit code: $exit_code"
        echo "$ERROR We are going to retry"
        run_ansible $1
    fi
}

# We run all the recipes separately to minimize faillure
echo "[+] Running all the playbook to setup the lab"
run_ansible build.yml

run_ansible ad-servers.yml

run_ansible ad-parent_domain.yml

# Wait after the child domain creation before adding servers
run_ansible ad-child_domain.yml
echo "$INFO Waiting 5 minutes for the child domain to be ready"
sleep 5m

run_ansible ad-members.yml

run_ansible ad-trusts.yml

run_ansible ad-data.yml

run_ansible ad-gmsa.yml

run_ansible laps.yml

run_ansible ad-relations.yml

run_ansible adcs.yml

run_ansible ad-acl.yml

run_ansible servers.yml

run_ansible security.yml

run_ansible vulnerabilities.yml

run_ansible reboot.yml

echo "$OK GOAD is successfully setup !"