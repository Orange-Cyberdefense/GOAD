#!/usr/bin/env bash

if [ ! -d "./.venv" ]
then
  echo '[+] venv not found, start python venv creation'
  python3 -m virtualenv .venv
  source .venv/bin/activate
  python3 -m pip install --upgrade pip
  python3 -m pip install -r requirements.txt
  exit 0
fi

# launch the app
source .venv/bin/activate
python3 goad.py $@
deactivate
