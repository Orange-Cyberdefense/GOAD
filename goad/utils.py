from pathlib import Path
import os
import random
import string

# constants
LAB = 'lab'
PROVIDER = 'provider'
PROVISIONER = 'provisioner'
IP_RANGE = 'ip_range'

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

# instance status
TO_PROVIDE = 'to_provide'
TO_PROVISION = 'to_provision'
READY = 'ready'


# TODO : create a class PathManager and use it



def get_ubuntu_jumpbox_key(lab_name, provider):
    return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'providers' + os.path.sep + provider + os.path.sep + 'ssh_keys' + os.path.sep + 'ubuntu-jumpbox.pem'


# extensions paths

def get_extensions_path():
    return project_path + os.path.sep + 'extensions'


def get_extension_providers_path(extension_name):
    return project_path + os.path.sep + 'extensions' + os.path.sep + extension_name + os.path.sep + 'providers'


def get_extension_ansible_path(extension_name):
    return project_path + os.path.sep + 'extensions' + os.path.sep + extension_name + os.path.sep + 'ansible'


def get_extension_inventory_path(extension_name):
    return get_extension_ansible_path(extension_name) + os.path.sep + 'inventory'


def get_extension_provider_path(extension_name, provider_name):
    return get_extension_providers_path(extension_name) + os.path.sep + provider_name + os.path.sep


def get_extension_provider_inventory_path(extension_name, provider_name):
    return get_extension_providers_path(extension_name) + os.path.sep + provider_name + os.path.sep + 'inventory'


class SingletonMeta(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]


class Utils:
    @staticmethod
    def list_folders(path):
        if os.path.isdir(path):
            return [p.name for p in Path(path).iterdir() if p.is_dir()]
        else:
            return []

    @staticmethod
    def get_relative_path(path):
        return path[len(project_path):]

    @staticmethod
    def transform_local_path_to_remote_path(origin, remote_project_path):
        return remote_project_path + origin[len(project_path):]

    @staticmethod
    def get_random_string(length):
        # choose from all lowercase letter
        letters = string.ascii_lowercase
        result_str = ''.join(random.choice(letters) for i in range(length))
        return result_str

    @staticmethod
    def replace_in_file(filename, search_string, new_string):
        if os.path.isfile(filename):
            # Read in the file
            with open(filename, 'r') as file:
                filedata = file.read()

            # Replace the target string
            filedata = filedata.replace(search_string, new_string)

            # Write the file out again
            with open(filename, 'w') as file:
                file.write(filedata)
            return True
        return False
