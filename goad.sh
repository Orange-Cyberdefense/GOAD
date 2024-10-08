#!/usr/bin/env bash

py=python3
if [ ! -d "$HOME/.goad/.venv" ]
then
  if $py -m venv --help > /dev/null 2>&1; then
      echo "venv module is installed. continue"
  else
      echo "venv module is not installed."
      echo "please install python-venv according to your system"
      echo "exit"
      exit 0
  fi
  echo '[+] venv not found, start python venv creation'
  mkdir ~/.goad
  $py -m venv $HOME/.goad/.venv
  source $HOME/.goad/.venv/bin/activate
  $py -m pip install --upgrade pip
  export SETUPTOOLS_USE_DISTUTILS=stdlib
  $py -m pip install -r requirements.yml
  cd ansible
  ansible-galaxy install -r requirements.yml
  cd -
fi

# launch the app
source $HOME/.goad/.venv/bin/activate
$py goad.py $@
deactivate
