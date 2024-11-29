#!/usr/bin/env bash

py=python3
venv="$HOME/.goad/.venvdocker"

if [ ! -d "$venv" ]
then
  # Get the Python version (removes 'Python' from output)
  version=$($py --version 2>&1 | awk '{print $2}')
  # Convert the version to comparable format (removes the dot and treats it as an integer)
  version_numeric=$(echo $version | awk -F. '{printf "%d%02d%02d\n", $1, $2, $3}')
  # Check if the version is >= 3.8.0 and < 3.12.0
  if [ "$version_numeric" -ge 30800 ]; then
      # echo "Python version is >= 3.8.0"
      echo 'python version ok'
  else
      echo "Python version is outside the range >= 3.8.0"
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
  mkdir -p ~/.goad
  $py -m venv $venv
  source $venv/bin/activate
  $py -m pip install --upgrade pip
  export SETUPTOOLS_USE_DISTUTILS=stdlib
  $py -m pip install -r noansible_requirements.yml
fi

if groups $USER | grep &>/dev/null '\bdocker\b'; then
  echo "User is in the docker group"
  use_sudo=""
else
  echo "User is not in the docker group"
  use_sudo="sudo"
fi

ALREADY_BUILD=$($use_sudo docker images |grep -c "goadansible")
if [[ $ALREADY_BUILD -eq 0 ]]; then
  echo "[+] Build container"
  $use_sudo docker build -t goadansible .
  echo "${OK} Container goadansible creation complete"
fi

echo "goad with docker, disable local and runner provisioner"
# launch the app
source $venv/bin/activate
$py goad.py -m docker -d local -d runner $@
deactivate
