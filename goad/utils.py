from pathlib import Path
import os

# constants
LAB = 'lab'
PROVIDER = 'provider'
PROVIDING_METHOD = 'providing_method'

# log level
INFO = 5
VERBOSE = 2
DEBUG = 1

# providers
AWS = 'aws'
VIRTUALBOX = 'virtualbox'
AZURE = 'azure'
VMWARE = 'vmware'
PROXMOX = 'proxmox'
ALLOWED_PROVIDERS = [AWS, VIRTUALBOX, AZURE, VMWARE, PROXMOX]

project_path = os.path.normpath(os.path.dirname(os.path.abspath(__file__)) + os.path.sep + '..')


def get_labs_path():
    return project_path + os.path.sep + 'ad'


def get_providers_path(lab_name):
    return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'providers'


def get_extensions_path(lab_name):
    return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'extensions'


class SingletonMeta(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]


class Utils:
    @staticmethod
    def list_folders(path):
        return [p.name for p in Path(path).iterdir() if p.is_dir()]
