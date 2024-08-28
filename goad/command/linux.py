import sys

from goad.command.cmd import Command
import subprocess
from goad.log import Log
from goad.utils import *


class LinuxCommand(Command):

    def run_shell(self, command, path):
        try:
            Log.info('CWD: ' + get_relative_path(str(path)))
            Log.cmd(command)
            subprocess.run(command, cwd=path, shell=True)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")

    def run_command(self, command, path):
        result = None
        try:
            Log.info('CWD: ' + get_relative_path(str(path)))
            Log.cmd(command)
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout, shell=True)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return result

    def check_vagrant(self):
        command = 'which vagrant >/dev/null'
        try:
            subprocess.run(command, shell=True, check=True)
            Log.success('vagrant found in PATH')
            return True
        except subprocess.CalledProcessError as e:
            Log.error('vagrant not found in PATH')
            return False

    def check_vmware(self):
        command = 'which vmrun >/dev/null'
        try:
            subprocess.run(command, shell=True, check=True)
            Log.success('vmware workstation found in PATH')
            return True
        except subprocess.CalledProcessError as e:
            Log.error('vmware workstation not found in PATH')
            return False

    def run_vagrant(self, args, path):
        result = None
        try:
            command = ['vagrant']
            command += args
            Log.info('CWD: ' + get_relative_path(str(path)))
            Log.cmd(' '.join(command))
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return result

    def check_terraform(self):
        command = 'which terraform >/dev/null'
        try:
            subprocess.run(command, shell=True, check=True)
            Log.success('terraform found in PATH')
            return True
        except subprocess.CalledProcessError as e:
            Log.error('terraform not found in PATH')
            return False

    def run_terraform(self, args, path):
        result = None
        try:
            command = ['terraform']
            command += args
            Log.info('CWD: ' + get_relative_path(str(path)))
            Log.cmd(' '.join(command))
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return result

    def run_terraform_output(self, args, path):
        result = None
        try:
            command = ['terraform', 'output', '-raw']
            command += args
            Log.info('CWD: ' + get_relative_path(str(path)))
            Log.cmd(' '.join(command))
            result = subprocess.run(command, cwd=path,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE,
                                    text=True
                                    )
            if result.returncode != 0:
                print(f"Error: {result.stderr}")
                return None

            return result.stdout
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return None

    def run_ansible(self, args, path):
        result = None
        try:
            command = 'ansible-playbook '
            command += args
            Log.info('CWD: ' + get_relative_path(str(path)))
            Log.cmd(command)
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout, shell=True)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
            return False
        return result

    def get_azure_account_output(self):
        result = subprocess.run(
            ["az", "account", "list", "--output", "json"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if result.returncode != 0:
            print(f"Error: {result.stderr}")
            return None

        return result.stdout

    def rsync(self, source, destination, ssh_key):
        # rsync = f'rsync -a --exclude-from='.gitignore' -e "ssh -o 'StrictHostKeyChecking no' -i $CURRENT_DIR/ad/$lab/providers/$provider/ssh_keys/ubuntu-jumpbox.pem" "$CURRENT_DIR/" goad@$public_ip:~/GOAD/'
        Log.info(f'Launch Rsync {source} -> {destination}')
        ssh_command = f"ssh -o 'StrictHostKeyChecking no' -i {ssh_key}"
        command = f'rsync -a --exclude-from=".gitignore" -e "{ssh_command}" {source} {destination}'
        self.run_shell(command, source)
