from abc import ABC
from goad.config import Config
import os
import platform
from goad.command.linux import LinuxCommand
from goad.command.windows import WindowsCommand
from goad.utils import *
from goad.log import Log


class Provider(ABC):
    lab_name = ''
    provider_name = None
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_REMOTE]
    use_jumpbox = False

    def __init__(self, lab_name):
        self.lab_name = lab_name
        self.path = None
        if platform.system() == 'Windows':
            self.command = WindowsCommand()
        else:
            self.command = LinuxCommand()

    def set_instance_path(self, provider_instance_path):
        self.path = provider_instance_path

    def check(self):
        pass

    def install(self):
        pass

    def destroy(self):
        pass

    def start(self):
        pass

    def stop(self):
        pass

    def status(self):
        pass

    def start_vm(self, vm_name):
        pass

    def stop_vm(self, vm_name):
        pass

    def destroy_vm(self, vm_name):
        pass

    def restart_vm(self, vm_name):
        self.stop_vm(vm_name)
        self.start_vm(vm_name)
