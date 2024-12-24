import configparser
from goad.goadpath import GoadPath
from goad.utils import *
from goad.log import Log
from goad.dependencies import Dependencies


class Config:
    config = None

    def __init__(self):
        if not os.path.isdir(GoadPath.get_config_path()):
            Log.info(f'goad config path not found, create dir {GoadPath.get_config_path()}')
            os.mkdir(GoadPath.get_config_path(), 0o750)
        if not os.path.isfile(GoadPath.get_config_file()):
            Log.info(f'goad config file not found, create file {GoadPath.get_config_file()}')
            self.create_config_file()

    def get_config_parser(self):
        return self.config

    def create_config_file(self):
        cfgfile = open(GoadPath.get_config_file(), "w")
        config = configparser.ConfigParser(allow_no_value=True)

        config.add_section('default')
        config.set('default', '; lab: GOAD / GOAD-Light / MINILAB / NHA / SCCM')
        config.set('default', 'lab', 'GOAD')

        config.set('default', '; provider : virtualbox / vmware / vmware_esxi / aws / azure / proxmox')
        config.set('default', 'provider', 'vmware')

        config.set('default', "; provisioner method : local / remote")
        config.set('default', 'provisioner', 'local')

        config.set('default', '; ip_range (3 first ip digits)')
        config.set('default', 'ip_range', '192.168.56')

        config.add_section('aws')
        config.set('aws', 'aws_region', 'eu-west-3')
        config.set('aws', 'aws_zone', 'eu-west-3c')

        config.add_section('azure')
        config.set('azure', 'az_location', 'westeurope')

        config.add_section('proxmox')
        config.set('proxmox', 'pm_api_url', 'https://192.168.1.1:8006/api2/json')
        config.set('proxmox', 'pm_user', 'infra_as_code@pve')
        config.set('proxmox', 'pm_node', 'GOAD')
        config.set('proxmox', 'pm_pool', 'GOAD')
        config.set('proxmox', 'pm_full_clone', 'false')
        config.set('proxmox', 'pm_storage', 'local')
        config.set('proxmox', 'pm_vlan', '10')
        config.set('proxmox', 'pm_network_bridge', 'vmbr3')
        config.set('proxmox', 'pm_network_model', 'e1000')

        config.add_section('proxmox_templates_id')
        config.set('proxmox_templates_id', 'WinServer2019_x64', '102')
        config.set('proxmox_templates_id', 'WinServer2016_x64', '103')
        config.set('proxmox_templates_id', 'WinServer2019_x64_utd', '104')
        config.set('proxmox_templates_id', 'Windows10_22h2_x64', '105')

        config.add_section('ludus')
        config.set('ludus', '; api key must not have % if you have a % in it, change it by a %%')
        config.set('ludus', 'ludus_api_key', 'change_me')
        config.set('ludus', 'use_impersonation', 'yes')

        config.add_section('vmware_esxi')
        config.set('vmware_esxi', 'esxi_hostname', '10.10.10.10')
        config.set('vmware_esxi', 'esxi_username', 'root')
        config.set('vmware_esxi', 'esxi_password', 'password')
        config.set('vmware_esxi', 'esxi_net_nat', 'VM Network')
        config.set('vmware_esxi', 'esxi_net_domain', 'GOAD-LAN')
        config.set('vmware_esxi', 'esxi_datastore', 'datastore1')
        config.write(cfgfile)
        cfgfile.close()

    def merge_config(self, args):
        """
        Merge the configuration with the script arguments
        :param args: goad.py arguments
        :return: goad.Config object
        """
        self.config = configparser.ConfigParser()
        self.config.read(GoadPath.get_config_file())
        if args is not None:
            if args.lab:
                self.set_value('default', LAB, args.lab)
            if args.provider:
                self.set_value('default', PROVIDER, args.provider)
            if args.method:
                self.set_value('default', PROVISIONER, args.method)
            if args.ip_range:
                self.set_value('default', IP_RANGE, args.ip_range)
            if args.disable_dependencies:
                for disable_dependence in args.disable_dependencies:
                    if disable_dependence == 'vmware':
                        Dependencies.vmware_enabled = False
                    elif disable_dependence == 'vmware_esxi':
                        Dependencies.vmware_esxi_enabled = False
                    elif disable_dependence == 'virtualbox':
                        Dependencies.virtualbox_enabled = False
                    elif disable_dependence == 'azure':
                        Dependencies.azure_enabled = False
                    elif disable_dependence == 'aws':
                        Dependencies.aws_enabled = False
                    elif disable_dependence == 'ludus':
                        Dependencies.ludus_enabled = False
                    elif disable_dependence == 'proxmox':
                        Dependencies.proxmox_enabled_enabled = False
                    elif disable_dependence == 'local':
                        Dependencies.provisioner_local_enabled = False
                    elif disable_dependence == 'runner':
                        Dependencies.provisioner_runner_enabled = False
                    elif disable_dependence == 'remote':
                        Dependencies.provisioner_remote_enabled = False
                    elif disable_dependence == 'docker':
                        Dependencies.provisioner_docker_enabled = False
        return self

    def get_value(self, section, key, fallback=None):
        return self.config.get(section, key, fallback=fallback)

    def set_value(self, section, key, value):
        return self.config.set(section, key, value)

    def show(self):
        for section in self.config.sections():
            Log.basic(f'[yellow]\\[{section}][/yellow]')
            for key in self.config[section]:
                Log.basic(f' {key} : {self.config[section][key]}')
            Log.basic('')
