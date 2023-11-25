#!/bin/bash

if ! command -v sudo &> /dev/null
then 
  echo "sudo not installed, please install before running this script"
  exit 1
fi

sudo apt update
sudo apt install git vim tmux curl gnupg software-properties-common mkisofs

######################################################################################################
# PACKER
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install packer

######################################################################################################
# TERRAFORM
# Install the HashiCorp GPG key.
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Verify the key's fingerprint.
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

# add terraform sourcelist
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# update apt and install terraform
sudo apt update && sudo apt install terraform

######################################################################################################
# ANSIBLE
sudo apt install python3-pip python3-venv 

python3 -m venv .venv
source .venv/bin/activate

python3 -m pip install --upgrade pip
python3 -m pip install ansible-core==2.12.6
python3 -m pip install pywinrm

######################################################################################################
# ANSIBLE Galaxy
ansible-galaxy install -r ansible/requirements.yml
