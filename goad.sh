#!/usr/bin/env bash

py=python3
venv="$HOME/.goad/.venv"
requirement_file="requirements.yml"

if [ ! -d "$venv" ]
then
  # Get the Python version (removes 'Python' from output)
  version=$($py --version 2>&1 | awk '{print $2}')
  echo "Python version in use : $version"
  # Convert the version to comparable format (removes the dot and treats it as an integer)
  version_numeric=$(echo $version | awk -F. '{printf "%d%02d%02d\n", $1, $2, $3}')
  # Check if the version is >= 3.8.0
  if [ "$version_numeric" -ge 30800 ]; then
      # echo "Python version is >= 3.8.0
      echo 'python version >= 3.8 ok'
      if [ "$version_numeric" -lt 31100 ]; then
        # python version < 3.11
        requirement_file="requirements.yml"
      else
        # python version >= 3.11
        requirement_file="requirements_311.yml"
      fi
  else
      echo "Python version is < 3.8 please update python before install"
      exit
  fi

  if [ "$($py -m venv -h 2>/dev/null | grep -i 'usage:')" ]; then
    echo "venv module is installed. continue"
  else
    echo "venv module is not installed."
    echo "please install $py-venv according to your system"
    echo "exit"
    exit 0
  fi

  echo '[+] venv not found, start python venv creation'
  mkdir -p ~/.goad
  $py -m venv $venv
  source $venv/bin/activate
  if [ $? -eq 0 ]; then
    $py -m pip install --upgrade pip
    export SETUPTOOLS_USE_DISTUTILS=stdlib
    $py -m pip install -r $requirement_file
    cd ansible
    ansible-galaxy install -r $requirement_file
    cd -
  else
    echo "Error in venv creation"
    rm -rf $venv
    exit 0
  fi
fi

# launch the app
source $venv/bin/activate
$py goad.py $@
deactivate
