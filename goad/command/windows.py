import os
from goad.command.cmd import Command
import subprocess
from goad.log import Log


class WindowsCommand(Command):

    def __init__(self):
        super().__init__()
        self.vagrant_bin = 'vagrant.exe'
        self.terraform_bin = 'terraform.exe'

    def file_exist(self, file):
        exist = os.path.isfile(file)
        if exist:
            Log.success(f'File {file} present in the file system')
        return exist

    def is_in_path(self, bin_file):
        command = f'where {bin_file} >nul'
        try:
            subprocess.run(command, shell=True, check=True)
            Log.success(f'{bin_file} found in PATH')
            return True
        except subprocess.CalledProcessError as e:
            Log.error(f'{bin_file} not found in PATH')
            return False

    # CHECK
    def check_gem(self, gem_name):
        # not needed
        pass

    def check_vmware(self):
        return self.file_exist("c:\\Program Files (x86)\\VMware\\VMware Workstation\\vmrun.exe")

    def check_vmware_utility(self):
        return self.file_exist("c:\\Program Files\\VagrantVMwareUtility\\vagrant-vmware-utility.exe")

    def check_ovftool(self):
        return self.file_exist("c:\\Program Files\\VMware\\VMware OVF Tool\\ovftool.exe")

    def check_virtualbox(self):
        return self.file_exist("c:\\Program Files\\Oracle\\VirtualBox\\VBoxManage.exe")

    def check_terraform(self):
        return self.is_in_path('terraform.exe')

    def check_ludus(self):
        return False
