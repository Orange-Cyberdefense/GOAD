from pathlib import Path
import os
import random
import string
import ipaddress
import platform

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
VMWARE_ESXI = 'vmware_esxi'
PROXMOX = 'proxmox'
LUDUS = 'ludus'
ALLOWED_PROVIDERS = [AWS, VIRTUALBOX, AZURE, VMWARE, VMWARE_ESXI, PROXMOX, LUDUS]

# provisioning method
PROVISIONING_LOCAL = 'local'
PROVISIONING_RUNNER = 'runner'
PROVISIONING_REMOTE = 'remote'
PROVISIONING_VM = 'vm'
PROVISIONING_DOCKER = 'docker'
ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_REMOTE, PROVISIONING_VM, PROVISIONING_RUNNER, PROVISIONING_DOCKER]

# provisioner allowed
# AWS_ALLOWED_PROVISIONER = [PROVISIONING_REMOTE]
# AZURE_ALLOWED_PROVISIONER = [PROVISIONING_REMOTE]
# PROXMOX_ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER]
# VMWARE_ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER]
# VIRTUALBOX_ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER]
# LUDUS_ALLOWED_PROVISIONER = [PROVISIONING_LOCAL, PROVISIONING_RUNNER]

project_path = os.path.normpath(os.path.dirname(os.path.abspath(__file__)) + os.path.sep + '..')

# instance status
CREATED = 'not provided'
PROVIDED = 'ready for provisioning'
READY = 'installed'

# tasks
TASK_INSTALL = 'install'
TASK_CHECK = 'check'
TASK_START = 'start'
TASK_STOP = 'stop'
TASK_RESTART = 'restart'
TASK_DESTROY = 'destroy'
TASK_STATUS = 'status'
TASK_SNAPSHOT = 'snapshot'
TASK_RESET = 'reset'


class SingletonMeta(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]


class Utils:

    @staticmethod
    def is_wsl():
        version = platform.uname().release
        if version.endswith("-Microsoft"):
            return True
        elif version.endswith("microsoft-standard-WSL2"):
            return True
        return False

    @staticmethod
    def is_windows():
        if not Utils.is_wsl() and platform.system() == 'Windows':
            return True
        return False

    @staticmethod
    def confirm(message):
        result = input(f"{message}")
        if result == "y" or result == "Y" or result == "Yes":
            return True
        return False

    @staticmethod
    def is_valid_ipv4(ip):
        try:
            # Try to create an IPv4 object from the input
            ipaddress.IPv4Address(ip)
            return True
        except ValueError:
            return False

    @staticmethod
    def list_folders(path):
        if os.path.isdir(path):
            return [p.name for p in Path(path).iterdir() if p.is_dir()]
        else:
            return []

    @staticmethod
    def list_files(path):
        f = []
        for (dirpath, dirnames, filenames) in os.walk(path):
            f.extend(filenames)
            break
        return f

    @staticmethod
    def get_relative_path(path):
        return path[len(project_path):]

    @staticmethod
    def transform_local_path_to_remote_path(origin, remote_project_path):
        result_path = remote_project_path + origin[len(project_path):]
        if Utils.is_windows():
            result_path = result_path.replace('\\', '/')
        return result_path

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
