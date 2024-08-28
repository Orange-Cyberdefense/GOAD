import configparser
from rich import print

from goad.utils import *
from goad.log import Log


class Config:
    config = None

    def __init__(self):
        self.value = None

    def merge_config(self, args):
        """
        Merge the configuration with the script arguments
        :param args: goad.py arguments
        :return: goad.Config object
        """
        self.config = configparser.ConfigParser()
        self.config.read('goad.ini')
        if args is not None:
            if args.lab:
                self.set(LAB, args.lab)
            if args.provider:
                self.set(PROVIDER, args.provider)
            if args.method:
                self.set(PROVISIONER, args.provider)
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

