from pathlib import Path
import os

# constants
LAB = 'lab'
PROVIDER = 'provider'
PROVISIONER = 'provisioner'

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

# provisioning method
PROVISIONING_LOCAL = 'local'
PROVISIONING_RUNNER = 'runner'
PROVISIONING_DOCKER = 'docker'
PROVISIONING_REMOTE = 'remote'
ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_REMOTE]

# provisioner allowed
AWS_ALLOWED_PROVISIONER = [PROVISIONING_REMOTE]
AZURE_ALLOWED_PROVISIONER = [PROVISIONING_REMOTE]
PROXMOX_ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER]
VMWARE_ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER]
VIRTUALBOX_ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER]

project_path = os.path.normpath(os.path.dirname(os.path.abspath(__file__)) + os.path.sep + '..')


def get_project_path():
    return project_path + os.path.sep


def get_labs_path():
    return project_path + os.path.sep + 'ad'


def get_relative_path(path):
    return path[len(project_path):]


def transform_path(origin, remote_project_path):
    return remote_project_path + origin[len(project_path):]


def get_providers_path(lab_name):
    return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'providers'


def get_provisioner_path():
    return project_path + os.path.sep + 'ansible'


def get_global_inventory_path():
    return project_path + os.path.sep + 'globalsettings.ini'


def get_lab_inventory_path(lab_name):
    return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'data' + os.path.sep + 'inventory'


def get_provider_inventory_path(lab_name, provider):
    return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'providers' + os.path.sep + provider + os.path.sep + 'inventory'


def get_ubuntu_jumpbox_key(lab_name, provider):
    return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'providers' + os.path.sep + provider + os.path.sep + 'ssh_keys' + os.path.sep + 'ubuntu-jumpbox.pem'


def get_script_path(script):
    return project_path + os.path.sep + 'scripts' + os.path.sep + script


def get_playbooks_lab_config():
    return project_path + os.path.sep + 'playbooks.yml'


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
