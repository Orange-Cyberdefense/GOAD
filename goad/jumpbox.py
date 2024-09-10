import platform
from goad.command.linux import LinuxCommand
from goad.command.windows import WindowsCommand
from goad.exceptions import JumpBoxInitFailed
from goad.log import Log
from goad.utils import *
from goad.goadpath import GoadPath


class JumpBox:

    def __init__(self, instance):
        self.lab_name = instance.lab_name
        self.instance_path = instance.instance_path
        self.provider = instance.provider
        self.ssh_key = self.get_jumpbox_key()
        self.ip = self.provider.get_jumpbox_ip()
        self.username = 'goad'
        if platform.system() == 'Windows':
            self.command = WindowsCommand()
        else:
            self.command = LinuxCommand()
        if os.path.isfile(self.ssh_key) is None:
            Log.error('Missing ssh file JumpBox remote connection')
        if self.ip is None:
            Log.error('Missing ip for JumpBox remote connection')

    def provision(self):
        script_name = self.provider.jumpbox_setup_script
        script_file = GoadPath.get_script_file(script_name)
        if not os.path.isfile(script_file):
            Log.error(f'script file: {script_file} not found !')
            return None
        self.run_script(script_file)

    def get_jumpbox_key(self):
        return self.instance_path + os.path.sep + 'ssh_keys' + os.path.sep + 'ubuntu-jumpbox.pem'

    def ssh(self):
        ssh_cmd = f"ssh -o 'StrictHostKeyChecking no' -i {self.ssh_key} {self.username}@{self.ip}"
        self.command.run_shell(ssh_cmd, project_path)

    def run_script(self, script):
        ssh_cmd = f"ssh -o 'StrictHostKeyChecking no' -i {self.ssh_key} {self.username}@{self.ip} 'bash -s' < {script}"
        self.command.run_shell(ssh_cmd, project_path)

    def sync_sources(self):
        """
        rsync ansible folder to the jumpbox ip
        :return:
        """
        # # rsync -a --exclude-from='.gitignore' -e "ssh -o 'StrictHostKeyChecking no' -i $CURRENT_DIR/ad/$lab/providers/$provider/ssh_keys/ubuntu-jumpbox.pem" "$CURRENT_DIR/" goad@$public_ip:~/GOAD/
        source = GoadPath.get_project_path()
        if Utils.is_valid_ipv4(self.ip):
            destination = f'{self.username}@{self.ip}:~/GOAD/'
            self.command.rsync(source, destination, self.ssh_key)

            # workspace
            source = self.instance_path
            destination = f'{self.username}@{self.ip}:~/GOAD/workspace/'
            self.command.rsync(source, destination, self.ssh_key, False)
        else:
            Log.error('Can not sync source jumpbox ip is invalid')

        # # sync sources:
        # # ansible/
        # # ad/<lab>/
        # # scripts/
        # # workspace/<instance_id>/
        # # globalsettings.ini
        # sources = [GoadPath.get_provisioner_path(), GoadPath.get_lab_path(self.lab_name), GoadPath.get_script_path(), self.instance_path, GoadPath.get_global_inventory_path()]
        # destination = f'{self.username}@{self.ip}:~/GOAD/'
        # for source in sources:
        #     self.command.scp(source, destination + Utils.get_relative_path(source), self.ssh_key)

    def run_command(self, command, path):
        ssh_cmd = f"ssh -t -o 'StrictHostKeyChecking no' -i {self.ssh_key} {self.username}@{self.ip} 'cd {path} && {command}'"
        result = self.command.run_command(ssh_cmd, project_path)
        return result
