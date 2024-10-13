from abc import ABC
from goad.command.linux import LinuxCommand
from goad.command.wsl import WslCommand
from goad.goadpath import GoadPath
from goad.utils import Utils


class Provisioner(ABC):
    lab_name = ''
    provider_name = ''
    provisioner_name = None

    def __init__(self, lab_name, provider):
        self.lab_name = lab_name
        self.provider_name = provider.provider_name
        self.provider = provider
        self.path = GoadPath.get_provisioner_path()
        self.instance_path = ''
        if Utils.is_wsl():
            self.command = WslCommand()
        else:
            self.command = LinuxCommand()

    def set_instance_path(self, path):
        self.instance_path = path

    def run(self, arg):
        pass

    def run_extension(self, arg, current_instance_extensions):
        pass

    def run_from(self, arg):
        pass

    def update_jumpbox_ip(self, ip):
        pass
