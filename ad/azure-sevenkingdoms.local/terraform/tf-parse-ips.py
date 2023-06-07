#!/usr/bin/env python3
import json, yaml, sys, getopt, csv, time

TF_STATE_FILE='./terraform.tfstate'
TF_DATA=''

def loadTerraformState():
    try:
        with open(TF_STATE_FILE) as f:
            return json.load(f)
    except Exception as e:
        print('Error loading Terraform state file (%s)' % TF_STATE_FILE)
        exit()

TF_DATA=loadTerraformState()

def moduleExits(module_name):
    for res in TF_DATA['resources']:
        if 'module' in res:
            module = res['module'].split('.')[1]
            if module == module_name:
                return True
    return False

def extractHostsInfo():
    ini_output = ''

    output = {
        'all': {}
    }


    for module in TF_DATA['outputs']:
        mod = module.split('-')[1]
        output['all'][mod] = {
            'hosts': {}
        }
        ini_output=''
        if moduleExits(mod):
            hosts = TF_DATA['outputs'][module]['value']
            for host in hosts:
                hostname=host.split('-')[2]
                hostips=TF_DATA['outputs'][module]['value'][host]
                for hostip in hostips:
                    ip=TF_DATA['outputs'][module]['value'][host][hostip][0]
                    dns_domain=''
                    if hostname == "dc01":
                        dns_domain='dc01'
                        internalipv4="10.1.0.5"
                    elif hostname == "dc02":
                        dns_domain='dc01'
                        internalipv4="10.1.0.6"
                    elif hostname == "srv02":
                        dns_domain='dc02'
                        internalipv4="10.1.0.10"
                    elif hostname == "dc03":
                        dns_domain='dc03'
                        internalipv4="10.1.0.7"
                    elif hostname == "srv03":
                        dns_domain='dc03'
                        internalipv4="10.1.0.11"

                    if hostname == 'vpn':
                        ini_output+=f"{hostname} ansible_host={ip} internalipv4={internalipv4} dns_domain={dns_domain} dict_key={hostname}\n"

        print(ini_output)
    return output




hostsinfo = extractHostsInfo()


# print(yaml.safe_dump(hostsinfo, default_flow_style=False))


