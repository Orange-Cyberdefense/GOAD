from abc import ABC
from goad.config import Config
import os
import platform
from goad.command.linux import LinuxCommand
from goad.command.windows import WindowsCommand
from goad.utils import *


class Provisioner(ABC):
    lab_name = ''
    provider_name = ''
    provisioner_name = None

    def __init__(self, lab_name, provider):
        self.lab_name = lab_name
        self.provider_name = provider.provider_name
        self.provider = provider
        self.path = get_provisioner_path() + os.path.sep
        if platform.system() == 'Windows':
            self.command = WindowsCommand()
        else:
            self.command = LinuxCommand()

    def run(self, arg):
        pass

    def run_extension(self, arg):
        pass

    def run_from(self, arg):
        pass
