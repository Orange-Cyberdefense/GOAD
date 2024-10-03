#!/bin/bash

if ! command -v sudo &> /dev/null
then 
  echo "sudo not installed, please install before running this script"
  exit 1
fi

# Install git and python3
sudo apt-get update

######################################################################################################
# ANSIBLE
sudo apt install -y git python3-pip python3-venv 

python3 -m venv .venv
source .venv/bin/activate

python3 -m pip install --upgrade pip
python3 -m pip install ansible-core==2.12.6
python3 -m pip install pywinrm

######################################################################################################
# ANSIBLE Galaxy
ansible-galaxy install -r ansible/requirements.yml

echo "#################################################"
echo "You will need to run: source .venv/bin/activate"
echo "to get back in the python virtual environment"
echo "#################################################"