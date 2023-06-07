#!/bin/bash
set -euo pipefail

cp -r ../ad/azure-sevenkingdoms.local/ssh_keys ./

ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows build.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows ad-servers.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows ad-trusts.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows ad-data.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows laps.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows ad-relations.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows adcs.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows ad-acl.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows servers.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows security.yml
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-windows vulnerabilities.yml

ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory-linux vpn.yml
