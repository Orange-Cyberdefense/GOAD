import sys
import os
from goad.command.cmd import Command
import subprocess
from goad.goadpath import GoadPath
from goad.log import Log
from goad.utils import Utils


class WslCommand(Command):

    def __init__(self):
        super().__init__()
        self.vagrant_bin = 'vagrant.exe'
        self.terraform_bin = 'terraform.exe'

    def file_exist(self, file):
        exist = os.path.isfile(file)
        if exist:
            Log.success(f'File {file} present in the file system')
        return exist

    # CHECK
    def check_gem(self, gem_name):
        # not needed
        pass

    def check_vmware(self):
        return self.file_exist("/mnt/c/Program Files (x86)/VMware/VMware Workstation/vmrun.exe")

    def check_vmware_utility(self):
        return self.file_exist("/mnt/c/Program Files/VagrantVMwareUtility/vagrant-vmware-utility.exe")

    def check_ovftool(self):
        return self.file_exist("/mnt/c/Program Files/VMware/VMware OVF Tool/ovftool.exe")

    def check_virtualbox(self):
        return self.file_exist("/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe")

    def check_terraform(self):
        return self.is_in_path('terraform.exe')

    def check_ludus(self):
        return False

    # RUN
    # see Command
