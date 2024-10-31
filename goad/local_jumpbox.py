import os.path

from goad.command.linux import LinuxCommand
from goad.command.wsl import WslCommand
from goad.log import Log
from goad.utils import *
from goad.goadpath import GoadPath
from goad.jumpbox import JumpBox


class LocalJumpBox(JumpBox):

    def __init__(self, instance, creation=False):
        super().__init__(instance, creation)
        self.username = 'vagrant'

    def provision(self):
        script_name = self.provider.jumpbox_setup_script
        script_file = GoadPath.get_script_file(script_name)
        if not os.path.isfile(script_file):
            Log.error(f'script file: {script_file} not found !')
            return None
        self.command.scp(script_file, f'{self.username}@{self.ip}:~/setup.sh', self.ssh_key, self.instance_path)
        if Utils.is_windows():
            # if is windows convert line ending
            self.run_command("sudo apt update && sudo apt install -y dos2unix", '~')
            self.run_command("dos2unix setup.sh", '~')
        self.run_command('bash setup.sh', '~')

    def get_jumpbox_key(self, creation=False):
        if not creation:
            # example : workspace/bf0c11-goad-light-vmware/provider/.vagrant/machines/ELK/vmware_desktop/private_key
            provider_folder = f'{self.instance_path}/provider/.vagrant/machines/PROVISIONING/'.replace('/', os.path.sep)
            provider_folders = Utils.list_folders(provider_folder)
            if len(provider_folders) > 0:
                return provider_folder + provider_folders[0] + os.path.sep + 'private_key'
            key_supposed_path = provider_folder + '<provider_name>' + os.path.sep + 'private_key'
            Log.error(f'PROVISIONING ssh key not found at : {key_supposed_path}')
        return None

    def sync_sources(self):
        """
        rsync ansible folder to the jumpbox ip
        local_vm already got GOAD installed in ~/GOAD so the only thing to sync is the workspace folder
        :return:
        """
        if Utils.is_valid_ipv4(self.ip):
            # create workspace dir if not exist
            self.run_command('mkdir -p ~/GOAD/workspace/' + self.instance_id, '~')
            # workspace inventory files (no need -r as it will copy all the provider folder)
            for src_file in Utils.list_files(self.instance_path):
                source = self.instance_path + os.path.sep + src_file
                destination_file = f'~/GOAD/workspace/{self.instance_id}/{src_file}'
                destination = f'{self.username}@{self.ip}:{destination_file}'
                self.command.scp(source, destination, self.ssh_key, self.instance_path)
                if Utils.is_windows():
                    # if is windows convert line ending
                    self.run_command(f"dos2unix {destination_file}", '~')
        else:
            Log.error('Can not sync source jumpbox ip is invalid')
