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
                self.set(PROVIDING_METHOD, args.provider)
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

    def current_provider(self):
        return self.get(PROVIDER)

    def current_method(self):
        return self.get(PROVIDING_METHOD)

    def show_config(self):
        for key in self.config.sections():
            Log.success(f'*** {key} ***')
            for param in self.config[key]:
                config_value = str(self.config[key][param])
                if config_value == 'true':
                    config_value = f'[green]{config_value}[/green]'
                elif config_value == 'false':
                    config_value = f'[red]{config_value}[/red]'
                Log.info(f'{param} [white]'.ljust(48, '.') + f'[/white] {config_value}')
            print()
