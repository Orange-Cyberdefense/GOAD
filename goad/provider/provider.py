from abc import ABC
from goad.config import Config
import os
import platform
from goad.command.linux import LinuxCommand
from goad.command.windows import WindowsCommand
from goad.utils import *


class Provider(ABC):
    lab_name = ''
    provider_name = None

    def __init__(self, lab_name):
        self.lab_name = lab_name
        self.path = get_providers_path(lab_name) + os.path.sep + self.provider_name + os.path.sep
        if platform.system() == 'Windows':
            self.command = WindowsCommand()
        else:
            self.command = LinuxCommand()

    def check(self):
        pass

    def dependencies(self):
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
