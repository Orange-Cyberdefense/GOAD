import configparser
import os

from rich import print

from goad.goadpath import GoadPath
from goad.utils import *
from goad.log import Log


class Config:
    config = None

    def __init__(self):
        if not os.path.isdir(GoadPath.get_config_path()):
            Log.info(f'goad config path not found, create dir {GoadPath.get_config_path()}')
            os.mkdir(GoadPath.get_config_path(), 0o750)
        if not os.path.isfile(GoadPath.get_config_file()):
            Log.info(f'goad config file not found, create file {GoadPath.get_config_file()}')
            self.create_config_file()

    def create_config_file(self):
        # TODO change with config parser write : https://martin-thoma.com/configuration-files-in-python/
        conf_file_content = """[default]
; lab: GOAD / GOAD-Light / MINILAB / NHA / SCCM
lab = GOAD
; provider : virtualbox / vmware / aws / azure
provider = vmware
; provisioning method :
; local (default) : use subprocess to run ansible playbook
; runner : use ansible runner locally to run ansible playbook
; docker : use docker container to run ansible
; remote : launch ansible with ssh through the jump box (azure/aws only)
; if provisioner is not compatible it will be force to default
provisioner = local
;ip_range (3 first ip digits)
ip_range = 192.168.56
"""
        f = open(GoadPath.get_config_file(), "w")
        f.write(conf_file_content)
        f.close()

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
                self.set(LAB, args.lab)
            if args.provider:
                self.set(PROVIDER, args.provider)
            if args.method:
                self.set(PROVISIONER, args.method)
            if args.ip_range:
                self.set(IP_RANGE, args.ip_range)
            # if args.extensions:
            #     for extension in args.extensions:
            #         lab_extensions_key = self.current_lab() + '-extensions'
            #         if self.get(extension, lab_extensions_key) is not None:
            #             self.set(extension, 'true', lab_extensions_key)
        return self

    def get(self, key, section='default'):
        return self.config.get(section, key, fallback=None)

    def set(self, key, value, section='default'):
        return self.config.set(section, key, value)
