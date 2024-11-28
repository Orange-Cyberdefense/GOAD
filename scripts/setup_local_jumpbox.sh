#!/bin/bash

# Install git and python3
sudo apt-get update
sudo apt-get install -y git python3-venv python3-pip git

# git clone goad
GOAD_REPO=/home/vagrant/GOAD
GIT_FOLDER=$LOCALREPO/.git
if [ ! -d $GIT_FOLDER ]
then
    rm -rf $GOAD_REPO
    git clone https://github.com/Orange-Cyberdefense/GOAD.git $GOAD_REPO
    cd $GOAD_REPO
    # git checkout -b v3-beta origin/v3-beta
else
    cd $GOAD_REPO
    git pull
fi

# Install ansible and pywinrm
python3 -m pip install --upgrade pip
cd $GOAD_REPO
python3 -m pip install -r requirements.yml

cd $GOAD_REPO/ansible
/home/vagrant/.local/bin/ansible-galaxy install -r requirements.yml

# set color
sudo sed -i '/force_color_prompt=yes/s/^#//g' /home/*/.bashrc
sudo sed -i '/force_color_prompt=yes/s/^#//g' /root/.bashrc