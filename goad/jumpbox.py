import platform
from goad.command.linux import LinuxCommand
from goad.command.windows import WindowsCommand
from goad.exceptions import JumpBoxInitFailed
from goad.log import Log
from goad.utils import *


class JumpBox:

    def __init__(self, lab_name, provider):
        self.lab_name = lab_name
        self.provider = provider
        self.ssh_key = self._get_jumpbox_key()
        self.ip = provider.get_jumpbox_ip()
        self.username = 'goad'

        if platform.system() == 'Windows':
            self.command = WindowsCommand()
        else:
            self.command = LinuxCommand()

        if self.ip is None or self.ssh_key is None:
            raise JumpBoxInitFailed('Missing elements for JumpBox remote connection')

    def _get_jumpbox_key(self):
        ssh_key = get_ubuntu_jumpbox_key(self.lab_name, self.provider.provider_name)
        if not os.path.isfile(ssh_key):
            Log.error('Key file not found')
            return None
        return ssh_key

    def prepare_jumpbox(self):
        script_name = self.provider.jumpbox_setup_script
        script_file = get_script_path(script_name)
        if not os.path.isfile(script_file):
            Log.error(f'script file: {script_file} not found !')
            return None
        self.run_script(script_file)

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
        source = get_project_path()
        destination = f'{self.username}@{self.ip}:~/GOAD/'
        self.command.rsync(source, destination, self.ssh_key)

    def run_command(self, command, path):
        ssh_cmd = f"ssh -t -o 'StrictHostKeyChecking no' -i {self.ssh_key} {self.username}@{self.ip} 'cd {path} && {command}'"
        result = self.command.run_command(ssh_cmd, project_path)
        if result is None or result.returncode != 0:
            return False
        return True
