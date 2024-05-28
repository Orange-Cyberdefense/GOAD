#!/bin/bash
# Credit to SOC Fortress for this amazing pack
# credits : https://github.com/socfortress/Wazuh-Rules/blob/main/wazuh_socfortress_rules.sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

clear

## Continue?

## Check if system is based on yum or apt-get
if [ -n "$(command -v yum)" ]; then
    sys_type="yum"
    sep="-"
elif [ -n "$(command -v zypper)" ]; then
    sys_type="zypper"   
    sep="-"  
elif [ -n "$(command -v apt-get)" ]; then
    sys_type="apt-get"   
    sep="="
fi

## Prints information
logger() {
    now=$(date +'%m/%d/%Y %H:%M:%S')
    case $1 in 
        "-e")
            mtype="INFO:"
            message="$2"
            ;;
        "-w")
            mtype="WARNING:"
            message="$2"
            ;;
        *)
            mtype="INFO:"
            message="$1"
            ;;
    esac
    echo "$now $mtype $message"
}


## Check if Git exists
if ! command -v git &> /dev/null
then
    logger -e "git package could not be found. Please install with yum/apt-get install git."
    exit
else 
    logger -e "git package found. Continuing..."
fi


checkArch() {
    arch=$(uname -m)

    if [ "$arch" != "x86_64" ]; then
        logger -e "Incompatible system. This script must be run on a 64-bit system."
        exit 1
    fi
}

restartService() {
    if [ -n "$(ps -e | egrep '^\s*1\s.*systemd$')" ]; then
        eval "systemctl restart $1.service ${debug}"
        if [ "$?" != 0 ]; then
            logger -e "${1^} could not be restarted. Please check /var/ossec/logs/ossec.log for details."
            logger -e "An error has occurred. Attempting to restore backed up rules" 
            \cp -r /tmp/wazuh_rules_backup/* /var/ossec/etc/rules/
            chown wazuh:wazuh /var/ossec/etc/rules/*
            chmod 660 /var/ossec/etc/rules/*
            systemctl restart wazuh-manager
            rm -rf /tmp/Wazuh-Rules
        else
            sleep 1
        fi  
    elif [ -n "$(ps -e | egrep '^\s*1\s.*init$')" ]; then
        eval "chkconfig $1 on ${debug}"
        eval "service $1 restart ${debug}"
        eval "/etc/init.d/$1 start ${debug}"
        if [ "$?" != 0 ]; then
            logger -e "${1^} could not be restarted. Please check /var/ossec/logs/ossec.log for details."
            logger -e "An error has occurred. Attempting to restore backed up rules" 
            \cp -r /tmp/wazuh_rules_backup/* /var/ossec/etc/rules/
            chown wazuh:wazuh /var/ossec/etc/rules/*
            chmod 660 /var/ossec/etc/rules/*
            systemctl restart wazuh-manager
            rm -rf /tmp/Wazuh-Rules
        else
            sleep 1
        fi     
    elif [ -x "/etc/rc.d/init.d/$1" ]; then
        eval "/etc/rc.d/init.d/$1 start ${debug}"
        if [ "$?" != 0 ]; then
            logger -e "${1^} could not be restarted. Please check /var/ossec/logs/ossec.log for details."
        else
            logger "${1^} restarted"
        fi             
    else
        logger -e "${1^} could not restart. No service found on the system."
    fi
}

healthCheck() {
    cd /var/ossec || exit 1  # Set the current working directory to /var/ossec
    logger "Performing a health check"
    eval "service wazuh-manager restart ${debug}"
    sleep 20
    if [ -n "$(/var/ossec/bin/wazuh-control status | grep 'wazuh-logcollector not running...')" ]; then
        logger -e "Wazuh-Manager Service is not healthy. Please check /var/ossec/logs/ossec.log for details."
    else
        logger -e "Wazuh-Manager Service is healthy. Thanks for checking us out :) Get started with our free-for-life tier here: https://www.socfortress.co/trial.html Happy Defending!"
        rm -rf /tmp/Wazuh-Rules
    fi
}

## Install the required packages for the installation
cloneRules() {
    logger "Beginning the Install"

    if [ "$sys_type" == "yum" ]; then
        logger -e "Verifying that Wazuh-Manager software is installed... continued"
        if rpm -qa | grep -q wazuh-manager; then
            mkdir /tmp/wazuh_rules_backup
            logger -e "Backing up current rules into /tmp/wazuh_rules_backup/"
            \cp -r /var/ossec/etc/rules/* /tmp/wazuh_rules_backup/
            git clone https://github.com/socfortress/Wazuh-Rules.git /tmp/Wazuh-Rules
            cd /tmp/Wazuh-Rules || exit 1
            find . -name '*xml' -exec mv {} /var/ossec/etc/rules/ \;
            find /var/ossec/etc/rules/ -name 'decoder-linux-sysmon.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'yara_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'auditd_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'naxsi-opnsense_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'maltrail_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'decoder-manager-logs.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            /var/ossec/bin/wazuh-control info 2>&1 | tee /tmp/version.txt
            chown wazuh:wazuh /var/ossec/etc/rules/*
            chmod 660 /var/ossec/etc/rules/*
            systemctl restart wazuh-manager
            cd /var/ossec || exit 1
            rm -rf /tmp/Wazuh-Rules
        else 
            logger -e "Wazuh-Manager software could not be found or is not installed"
        fi
    elif [ "$sys_type" == "apt-get" ]; then
        logger -e "Verifying that Wazuh-Manager software is installed... continued"
        if apt list --installed | grep -q wazuh-manager; then
            mkdir /tmp/wazuh_rules_backup
            logger -e "Backing up current rules into /tmp/wazuh_rules_backup/"
            \cp -r /var/ossec/etc/rules/* /tmp/wazuh_rules_backup/
            git clone https://github.com/socfortress/Wazuh-Rules.git /tmp/Wazuh-Rules
            cd /tmp/Wazuh-Rules || exit 1
            find . -name '*xml' -exec mv {} /var/ossec/etc/rules/ \;
            find /var/ossec/etc/rules/ -name 'decoder-linux-sysmon.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'yara_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'auditd_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'naxsi-opnsense_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'maltrail_decoders.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            find /var/ossec/etc/rules/ -name 'decoder-manager-logs.xml' -exec mv {} /var/ossec/etc/decoders/ \;
            /var/ossec/bin/wazuh-control info 2>&1 | tee /tmp/version.txt
            chown wazuh:wazuh /var/ossec/etc/rules/*
            chmod 660 /var/ossec/etc/rules/*
            systemctl restart wazuh-manager
            cd /var/ossec || exit 1
            rm -rf /tmp/Wazuh-Rules
        else 
            logger -e "Wazuh-Manager software could not be found or is not installed"
        fi
    else
        logger "Continuing"
    fi

    if [ "$?" != 0 ]; then
        logger -e "An error has occurred. Attempting to restore backed up rules" 
        \cp -r /tmp/wazuh_rules_backup/* /var/ossec/etc/rules/
        chown wazuh:wazuh /var/ossec/etc/rules/*
        chmod 660 /var/ossec/etc/rules/*
        systemctl restart wazuh-manager
        cd /var/ossec || exit 1
        rm -rf /tmp/Wazuh-Rules
    else
        logger -e "Rules downloaded, attempting to restart the Wazuh-Manager service" 
        restartService "wazuh-manager"
        sleep 5
    fi     
}

main() {
    if [ "$EUID" -ne 0 ]; then
        logger -e "This script must be run as root."
        exit 1
    fi   

    checkArch
    cloneRules
    healthCheck
}

main "$@"
