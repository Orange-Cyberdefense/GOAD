#!/bin/bash

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
# sudo rm -f /etc/ssh/sshd_config.d/99-goad-locale.conf
sudo sed -i '/^SetEnv .*LANG=/d' /etc/ssh/sshd_config
echo 'SetEnv LANG=C.UTF-8 LC_ALL=C.UTF-8' | sudo tee -a /etc/ssh/sshd_config >/dev/null
sudo systemctl restart ssh

# Install git and python3
sudo apt-get update
sudo apt-get install -y git python3-venv python3-pip sshpass

#python3 -m venv .venv
#source .venv/bin/activate

# Install ansible and pywinrm
python3 -m pip install --upgrade pip --break-system-packages
python3 -m pip install ansible-core==2.18.3 --break-system-packages
python3 -m pip install pywinrm --break-system-packages

# Install the required ansible libraries
/home/goad/.local/bin/ansible-galaxy install -r /home/goad/GOAD/ansible/requirements.yml

# set color
sudo sed -i '/force_color_prompt=yes/s/^#//g' /home/*/.bashrc
sudo sed -i '/force_color_prompt=yes/s/^#//g' /root/.bashrc
