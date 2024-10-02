#!/usr/bin/env bash

if [ ! -d "./.venv" ]
then
  if python3 -m venv --help > /dev/null 2>&1; then
      echo "venv module is installed. continue"
  else
      echo "venv module is not installed. exit"
      exit 0
  fi
  echo '[+] venv not found, start python venv creation'
  python3 -m venv .venv
  source .venv/bin/activate
  python3 -m pip install --upgrade pip
  export SETUPTOOLS_USE_DISTUTILS=stdlib
  python3 -m pip install -r requirements.yml
  cd ansible
  ansible-galaxy install -r requirements.yml
  cd -
  exit 0
fi

# launch the app
source .venv/bin/activate
python3 goad.py $@
deactivate
