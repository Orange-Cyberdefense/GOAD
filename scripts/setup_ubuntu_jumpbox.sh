#!/bin/bash

# Install git and python3
sudo apt-get update
sudo apt-get install -y git python3-venv python3-pip

#python3 -m venv .venv
#source .venv/bin/activate

# Install ansible and pywinrm
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install ansible-core==2.12.6
sudo python3 -m pip install pywinrm

# Install the required ansible libraries
ansible-galaxy install -r ~/GOAD/ansible/requirements.yml

# set color
sudo sed -i '/force_color_prompt=yes/s/^#//g' /home/*/.bashrc
sudo sed -i '/force_color_prompt=yes/s/^#//g' /root/.bashrc
