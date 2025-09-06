#!/bin/bash

# Install git, pipx, build tools
sudo apt update
sudo apt install -y git pipx build-essential

# Use pipx to install correct ansible and pywinrm for Python version
pipx ensurepath

# Get the Python version (removes 'Python' from output)
version=$(python3 --version 2>&1 | awk '{print $2}')
echo "Python version in use : $version"
# Convert the version to comparable format (removes the dot and treats it as an integer)
version_numeric=$(echo $version | awk -F. '{printf "%d%02d%02d\n", $1, $2, $3}')

if [ "$version_numeric" -lt 31100 ]; then
  # python version < 3.11
  pipx install pip install ansible-core==2.12.6
  pipx inject ansible-core pywinrm
  # Install the required ansible libraries
  /home/goad/.local/bin/ansible-galaxy install -r /home/goad/GOAD/ansible/requirements.yml
else
  # python version >= 3.11
  pipx install pip install ansible-core==2.18.0
  pipx inject ansible-core pywinrm
  # Install the required ansible libraries
  /home/goad/.local/bin/ansible-galaxy install -r /home/goad/GOAD/ansible/requirements_311.yml
fi

# set color
sudo sed -i '/force_color_prompt=yes/s/^#//g' /home/*/.bashrc
sudo sed -i '/force_color_prompt=yes/s/^#//g' /root/.bashrc