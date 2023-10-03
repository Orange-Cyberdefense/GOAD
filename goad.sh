#!/usr/bin/env bash

ERROR=$(tput setaf 1; echo -n "[!]"; tput sgr0)
OK=$(tput setaf 2; echo -n "[✓]"; tput sgr0)
INFO=$(tput setaf 3; echo -n "[-]"; tput sgr0)

# Global variables
LAB=
PROVIDER=
METHOD=
JOB=
PROVIDERS="virtualbox vmware" # azure proxmox"
LABS=$(ls -A ad/ |grep -v 'template.lab')
TASKS="check install start stop status restart destroy"
METHODS="local docker"


print_usage() {
  echo "${ERROR} Usage: ./goad.sh -t task -l lab -p provider -m method"
  echo "${INFO} -t : task must be one of the following:"
  echo "   - check   : verify dependencies";
  echo "   - install : create the lab";
  echo "   - start   : start the lab";
  echo "   - stop    : stop the lab";
  echo "   - restart : reload the lab";
  echo "   - status  : show lab info and status";
  echo "   - destroy : trash the lab";
  echo "${INFO} -l : lab must be one of the following:"
  for lab in $LABS;  do
    echo "   - $lab";
  done
  echo "${INFO} -p : provider must be one of the following:"
  for p in $PROVIDERS;  do
    echo "   - $p";
  done
  echo "${INFO} -m : method must be one of the following (optional, default : local):"
  echo "   - local : to use local ansible install";
  echo "   - docker : to use docker ansible install";
  echo
  echo "${OK} example: ./goad.sh -t check -l sevenkingdoms.local -p virtualbox -m local";
  exit 0
}

function exists_in_list() {
    LIST=$1
    VALUE=$2
    echo $LIST | tr " " '\n' | grep -F -q -x "$VALUE"
}

while getopts t:l:p:m: flag
  do
      case "${flag}" in
          t) TASK=${OPTARG};;
          l) LAB=${OPTARG};;
          p) PROVIDER=${OPTARG};;
          m) METHOD=${OPTARG};;
      esac
  done

  if exists_in_list "$TASKS" "$TASK"; then
    echo "${OK} Task: $TASK"
  else
    echo "${ERROR} Task: \"$TASK\" unknow"
    print_usage
  fi

  if exists_in_list "$LABS" "$LAB"; then
    echo "${OK} Lab: $LAB"
  else
    echo "${ERROR} Lab: $LAB not allowed"
    print_usage
  fi

  if exists_in_list "$PROVIDERS" "$PROVIDER"; then
    echo "${OK} Provider: $PROVIDER"
  else
    echo "${ERROR} Provider: $PROVIDER not allowed"
    print_usage
  fi

  if [ -z $METHOD ]; then
     METHOD="local"
  else
    if exists_in_list "$METHODS" "$METHOD"; then
      echo "${OK} Method: $METHOD"
    else
      echo "${ERROR} Method: $METHOD not allowed"
      print_usage
    fi
  fi


install_templating(){
  lab=$1
  provider=$2
  method=$3

  case $provider in
    "proxmox")
      # TODO packer
      ;;
    *)
      ;;
  esac
}

install_providing(){
  lab=$1
  provider=$2

  case $provider in
    "virtualbox")
      if [ -d "ad/$lab/providers/virtualbox" ]; then
        cd "ad/$lab/providers/virtualbox"
        echo "${OK} launch vagrant"
        vagrant up
        result=$?
        if [ ! $result -eq 0 ]; then
          cd -
          echo "${ERROR} vagrant finish with error abort"
          exit 1
        fi
        cd -
      else
        echo "${ERROR} folder ad/$lab/providers/virtualbox not found"
        exit 1
      fi
      ;;
    "vmware")
      ;;
    "proxmox")
      ;;
    "azure")
      ;;
  esac
}

install_provisioning(){
  lab=$1
  provider=$2
  method=$3
  case $provider in
    "virtualbox"|"vmware")
      if [ -d "ad/$lab/providers/$provider" ]; then
        cd "ad/$lab/providers/$provider"
        echo "${OK} is vagrant up"
        vagrant status
        cd -

        case $method in
          "local")
              cd ansible
              export ANSIBLE_COMMAND="ansible-playbook -i ../ad/$lab/data/inventory -i ../ad/$lab/providers/$provider/inventory"
              ../scripts/provisionning.sh
              cd -
            ;;
          "docker")
              use_sudo=""
              if id -nG "$USER" | grep -qw "docker"; then
                  echo $USER belongs to docker group
              else
                  echo $USER does not belong to docker group
                  echo "${INFO} Root password could be asked for docker interaction"
                  use_sudo="sudo"
              fi

              ALREADY_BUILD=$($use_sudo docker images |grep -c "goadansible")
              if [[ $ALREADY_BUILD -eq 0 ]]; then
                echo "[+] Build container"
                $use_sudo docker build -t goadansible .
                echo "${OK} Container goadansible creation complete"
              fi
              echo "${OK} Start provisioning from docker"
              $use_sudo docker run -ti --rm --network host -h goadansible -v $(pwd):/goad -w /goad/ansible goadansible /bin/bash -c "ANSIBLE_COMMAND='ansible-playbook -i ../ad/$lab/providers/$provider/inventory' ../scripts/provisionning.sh"
            ;;
        esac
      else
        echo "${ERROR} folder ad/$lab/providers/$provider not found"
        exit 1
      fi
      ;;
    "proxmox")
      ;;
    "azure")
      ;;
  esac
}


install(){
  echo "${OK} Launch installation for: $LAB / $PROVIDER / $METHOD"
  install_providing $LAB $PROVIDER
  install_provisioning $LAB $PROVIDER $METHOD
}

check(){
  if [ -d "ad/$LAB/providers/$PROVIDER" ]; then
    echo "${OK} $LAB provider $PROVIDER folder exist "
  else
    echo "${ERROR} provider $PROVIDER not implemented for this lab"
    exit 1
  fi
  echo "${OK} Launch check : ./scripts/check.sh $PROVIDER $METHOD"
  ./scripts/check.sh $PROVIDER $METHOD
  check_result=$?
  if [ $check_result -eq 0 ]; then
    echo "${OK} Check is ok, you can start the installation"
  else
    echo "${ERROR} Check is not ok, please fix the errors and retry"
    echo "${INFO} You could also run the setup script"
  fi
}

start(){
  case $PROVIDER in
    "virtualbox"|"vmware")
      if [ -d "ad/$LAB/providers/$PROVIDER" ]; then
          cd "ad/$LAB/providers/$PROVIDER"
          echo "${OK} start vms"
          vagrant up
          cd -
      else
        echo "${ERROR} folder ad/$LAB/providers/$PROVIDER not found"
        exit 1
      fi
      ;;
    "proxmox")
      ;;
    "azure")
      ;;
  esac
}

stop(){
  case $PROVIDER in
    "virtualbox"|"vmware")
      if [ -d "ad/$LAB/providers/$PROVIDER" ]; then
          cd "ad/$LAB/providers/$PROVIDER"
          echo "${OK} stop vms"
          vagrant halt
          cd -
      else
        echo "${ERROR} folder ad/$LAB/providers/$PROVIDER not found"
        exit 1
      fi
      ;;
    "proxmox")
      ;;
    "azure")
      ;;
  esac
}

restart(){
  case $PROVIDER in
    "virtualbox"|"vmware")
      if [ -d "ad/$LAB/providers/$PROVIDER" ]; then
          cd "ad/$LAB/providers/$PROVIDER"
          echo "${OK} restart start vms"
          vagrant reload
          cd -
      else
        echo "${ERROR} folder ad/$LAB/providers/$PROVIDER not found"
        exit 1
      fi
      ;;
    "proxmox")
      ;;
    "azure")
      ;;
  esac
}

destroy(){
  case $PROVIDER in
    "virtualbox"|"vmware")
      if [ -d "ad/$LAB/providers/$PROVIDER" ]; then
          cd "ad/$LAB/providers/$PROVIDER"
          echo "${OK} destroy the lab"
          read -r -p "Are you sure? [y/N] " response
          case "$response" in
              [yY][eE][sS]|[yY]) 
                  vagrant destroy --force
                  ;;
              *)
                  echo "abort"
                  ;;
          esac
          cd -
      else
        echo "${ERROR} folder ad/$LAB/providers/$PROVIDER not found"
        exit 1
      fi
      ;;
    "proxmox")
      ;;
    "azure")
      ;;
  esac
}

status(){
  case $PROVIDER in
    "virtualbox"|"vmware")
      if [ -d "ad/$LAB/providers/$PROVIDER" ]; then
          cd "ad/$LAB/providers/$PROVIDER"
          vagrant status
      else
        echo "${ERROR} folder ad/$LAB/providers/$PROVIDER not found"
        exit 1
      fi
      ;;
    "proxmox")
      ;;
    "azure")
      ;;
  esac
}

main() {
  CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd $CURRENT_DIR
  case $TASK in
    check)
      check
      ;;
    install)
      install
      ;;
    status)
      status
      ;;
    start)
      start
      ;;
    stop)
      stop
      ;;
    restart)
      restart
      ;;
    destroy)
      destroy
      ;;
    *)
      ;;
  esac
}

main