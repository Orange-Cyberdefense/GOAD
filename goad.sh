#!/usr/bin/env bash

py=python3
venv="$HOME/.goad/.venv"

if [ ! -d "$venv" ]
then
  # Get the Python version (removes 'Python' from output)
  version=$($py --version 2>&1 | awk '{print $2}')
  # Convert the version to comparable format (removes the dot and treats it as an integer)
  version_numeric=$(echo $version | awk -F. '{printf "%d%02d%02d\n", $1, $2, $3}')
  # Check if the version is >= 3.8.0 and < 3.12.0
  if [ "$version_numeric" -ge 30800 ] && [ "$version_numeric" -lt 31200 ]; then
      # echo "Python version is >= 3.8.0 and < 3.12.0"
      echo 'python version ok'
  else
      echo "Python version is outside the range 3.8.0 to 3.12.0"
      exit
  fi

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
  $py -m venv $venv
  source $venv/bin/activate
  $py -m pip install --upgrade pip
  export SETUPTOOLS_USE_DISTUTILS=stdlib
  $py -m pip install -r requirements.yml
  cd ansible
  ansible-galaxy install -r requirements.yml
  cd -
fi

# launch the app
source $venv/bin/activate
$py goad.py $@
deactivate
