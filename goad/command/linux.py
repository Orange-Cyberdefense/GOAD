import sys
import os
from goad.command.cmd import Command
import subprocess

from goad.goadpath import GoadPath
from goad.log import Log
from goad.utils import Utils


class LinuxCommand(Command):

    def __init__(self):
        super().__init__()
        self.vagrant_bin = 'vagrant'
        self.terraform_bin = 'terraform'

    # CHECK
    def check_gem(self, gem_name):
        try:
            result = subprocess.run(['gem', 'list'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if gem_name in result.stdout:
                Log.success(f'ruby gem {gem_name} is installed')
                return True
            else:
                Log.warning(f'ruby gem {gem_name} not installed')
                return False
        except FileNotFoundError:
            Log.error("Ruby or gem is not installed or not found in PATH.")
            return False

    def check_vmware(self):
        return self.is_in_path('vmrun')

    def check_vmware_utility(self):
        try:
            result = subprocess.run(
                ['systemctl', 'is-active', '--quiet', 'vagrant-vmware-utility'],
                check=True
            )
            Log.success(f'vmware utility is installed')
            return True
        except subprocess.CalledProcessError:
            Log.error("vagrant-vmware-utility is not installed")
            return False

    def check_ovftool(self):
        try:
            result = subprocess.run(['ovftool', '-v'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd='.')
            fields = result.stdout.split(' ')
            if len(fields) > 2:
                version = fields[2]
                Log.success(f'Ovftool version {version} is installed')
                return True
            else:
                Log.error(f'Failed to parse ovftool version')
                return False
        except FileNotFoundError:
            Log.error("ovftool is not installed or not found in PATH.")
            return False

    def check_virtualbox(self):
        return self.is_in_path('VBoxManage')

    def check_ludus(self):
        return self.is_in_path('ludus')

    # RUN
    def run_ludus(self, args, path, api_key, user_id='', impersonation=False):
        env = os.environ.copy()
        if "LUDUS_API_KEY" not in os.environ:
            Log.info('Using api key from config file')
            env["LUDUS_API_KEY"] = api_key
        else:
            Log.info('Using api key from env')
        result = None
        try:
            command = 'ludus '
            if impersonation:
                command += f'--user {user_id} '
            command += args
            Log.info('CWD: ' + Utils.get_relative_path(str(path)))
            Log.cmd(command)
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout, shell=True, env=env)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return result.returncode == 0

    def run_ludus_result(self, command, path, api_key, do_log=True, user_id='', impersonation=False):
        result = None
        env = os.environ.copy()
        if "LUDUS_API_KEY" not in os.environ:
            Log.info('Using api key from config file')
            env["LUDUS_API_KEY"] = api_key
        else:
            Log.info('Using api key from env')
        try:
            cmd = ['ludus']
            if impersonation:
                cmd += ['--user', user_id]
            cmd += command
            if do_log:
                Log.info('CWD: ' + Utils.get_relative_path(str(path)))
                Log.cmd(' '.join(cmd))
            result = subprocess.run(cmd, cwd=path,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE,
                                    text=True,
                                    env=env
                                    )
            if result.returncode != 0:
                print(f"Error: {result.stderr}")
                return None

            return result.stdout
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return None

    def run_docker_ansible(self, args, path, ansible_path, sudo):
        result = None
        try:
            ansible_command = 'ansible-playbook '
            ansible_command += args
            command = f"{sudo} docker run -ti --rm --network host -h goadansible -v {GoadPath.get_project_path()}:/goad -w {ansible_path} goadansible /bin/bash -c '{ansible_command}'"
            Log.cmd(command)
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout, shell=True)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
            return False
        return result.returncode == 0

