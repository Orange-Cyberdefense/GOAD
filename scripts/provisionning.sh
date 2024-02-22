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

    # Run the command with a timeout of 30 minutes to avoid failure when ansible is stuck
    timeout 30m $ANSIBLE_COMMAND $1
    exit_code=$(echo $?)

    if [ $exit_code -eq 4 ]; then # ansible result code 4 = RUN_UNREACHABLE_HOSTS
        echo "$ERROR Error while running: $ANSIBLE_COMMAND $1"
        echo "$ERROR Some hosts were unreachable, we are going to retry"
        run_ansible $1

    elif [ $exit_code -eq 124 ]; then # Command has timed out, relaunch the ansible playbook
        echo "$ERROR Error while running: $ANSIBLE_COMMAND $1"
        echo "$ERROR Command has reached the timeout limit of 30 minutes, we are going to retry"
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
echo "[+] build.yml> 1/16"
run_ansible build.yml

echo "[+] ad-servers.yml> 2/16"
run_ansible ad-servers.yml

echo "[+] ad-parent_domain.yml> 3/16"
run_ansible ad-parent_domain.yml

# Wait after the child domain creation before adding servers
echo "[+] ad-child_domain.yml> 4/16"
run_ansible ad-child_domain.yml
echo "$INFO Waiting 5 minutes for the child domain to be ready"
sleep 5m

echo "[+] ad-members.yml> 5/16"
run_ansible ad-members.yml

echo "[+] ad-trusts.yml> 6/16"
run_ansible ad-trusts.yml

echo "[+] ad-data.yml> 7/16"
run_ansible ad-data.yml

echo "[+] ad-gmsa.yml> 8/16"
run_ansible ad-gmsa.yml

echo "[+] laps.yml> 9/16"
run_ansible laps.yml

echo "[+] ad-relations.yml> 10/16"
run_ansible ad-relations.yml

echo "[+] adcs.yml> 11/16"
run_ansible adcs.yml

echo "[+] ad-acl.yml> 12/16"
run_ansible ad-acl.yml

echo "[+] servers.yml> 13/16"
run_ansible servers.yml

echo "[+] security.yml> 14/16"
run_ansible security.yml

echo "[+] vulnerabilities.yml> 15/16"
run_ansible vulnerabilities.yml

echo "[+] reboot.yml> 16/16"
run_ansible reboot.yml

echo "$OK your lab is successfully setup ! have fun ;)"
