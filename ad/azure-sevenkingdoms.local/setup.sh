#!/bin/bash

sudo apt update
sudo apt install -y git python3-venv python3-pip

git clone --branch azure https://github.com/jarrault/GOAD.git
cd GOAD/ansible
python3 -m venv .venv
source .venv/bin/activate

python3 -m pip install --upgrade pip
python3 -m pip install ansible-core==2.12.6
python3 -m pip install pywinrm

ansible-galaxy install -r requirements.yml

ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory main.yml
