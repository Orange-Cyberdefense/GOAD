import subprocess
import psutil
import sys
from goad.log import Log
from goad.utils import Utils
from goad.dependencies import Dependencies

class Command:

    def __init__(self):
        self.vagrant_bin = ''
        self.terraform_bin = ''

    # CHECK
    def is_in_path(self, bin_file):
        command = f'which {bin_file} >/dev/null'
        try:
            subprocess.run(command, shell=True, check=True)
            Log.success(f'{bin_file} found in PATH')
            return True
        except subprocess.CalledProcessError as e:
            Log.error(f'{bin_file} not found in PATH')
            return False

    def check_vagrant(self):
        return self.is_in_path(self.vagrant_bin)

    def check_vagrant_plugin(self, plugin_name, mandatory=True):
        try:
            result = subprocess.run([self.vagrant_bin, 'plugin', 'list'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if plugin_name in result.stdout:
                Log.success(f'vagrant plugin {plugin_name} is installed')
                return True
            else:
                if not mandatory:
                    Log.warning(f'Missing vagrant plugin {plugin_name}')
                else:
                    Log.error(f'Missing vagrant plugin {plugin_name}')
                    return False
        except FileNotFoundError:
            Log.error("Vagrant is not installed or not found in PATH.")
            return False

    def check_vmware_utility(self):
        pass

    def check_ovftool(self):
        pass

    def check_gem(self, gem_name):
        pass

    def check_vmware(self):
        pass

    def check_virtualbox(self):
        pass

    def check_terraform(self):
        return self.is_in_path(self.terraform_bin)

    def check_aws(self):
        return self.is_in_path('aws')

    def check_azure(self):
        return self.is_in_path('az')

    def check_rsync(self):
        return self.is_in_path('rsync')

    def check_ansible(self):
        if not Dependencies.provisioner_local_enabled and not Dependencies.provisioner_runner_enabled:
            Log.info('skip ansible check as no local and runner provisionner enabled')
            return True
        checks = [
            self.is_in_path('ansible-playbook'),
            self.check_ansible_galaxy('ansible.windows'),
            self.check_ansible_galaxy('community.general'),
            self.check_ansible_galaxy('community.windows'),
        ]
        return all(checks)

    def check_ansible_galaxy(self, collection):
        try:
            result = subprocess.run(['ansible-galaxy', 'collection', 'list'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd='./ansible')
            if collection in result.stdout:
                Log.success(f'Ansible galaxy collection {collection} is installed')
                return True
            else:
                Log.error(f'Missing ansible-galaxy collection {collection}')
                return False
        except FileNotFoundError:
            Log.error("ansible-galaxy is not installed or not found in PATH.")
            return False

    def check_ludus(self):
        # linux only
        pass

    def check_disk(self, min_disk_gb=120):
        # If the system has multiple mountpoints, '.' will correctly calculate the available space on the current disk
        disk_usage = psutil.disk_usage('.')
        free_disk_gb = disk_usage.free / (1024 ** 3)  # Convert bytes to GB
        if free_disk_gb < min_disk_gb:
            Log.warning(f'not enough disk space, only {str(free_disk_gb)} Gb available')
            return False
        return True

    def check_ram(self, min_ram_gb=24):
        total_ram_gb = psutil.virtual_memory().total / (1024 ** 3)  # Convert bytes to GB
        if total_ram_gb < min_ram_gb:
            Log.error('not enough ram on the system')
            return False
        return True

    # RUN
    def run_shell(self, command, path):
        try:
            Log.info('CWD: ' + Utils.get_relative_path(str(path)))
            Log.cmd(command)
            subprocess.run(command, cwd=path, shell=True)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")

    def run_command(self, command, path):
        result = None
        try:
            Log.info('CWD: ' + Utils.get_relative_path(str(path)))
            Log.cmd(command)
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout, shell=True)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
            return False
        return result.returncode == 0

    def run_vagrant(self, args, path):
        result = None
        try:
            command = [self.vagrant_bin]
            command += args
            Log.info('CWD: ' + Utils.get_relative_path(str(path)))
            Log.cmd(' '.join(command))
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return result.returncode == 0

    def run_terraform(self, args, path):
        result = None
        try:
            command = [self.terraform_bin]
            command += args
            Log.info('CWD: ' + Utils.get_relative_path(str(path)))
            Log.cmd(' '.join(command))
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return result.returncode == 0

    def run_terraform_output(self, args, path):
        result = None
        try:
            command = [self.terraform_bin, 'output', '-raw']
            command += args
            Log.info('CWD: ' + Utils.get_relative_path(str(path)))
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

    def run_ludus(self, args, path, api_key, user_id='', impersonation=False):
        # linux only
        pass

    def run_docker_ansible(self, args, path, ansible_path, sudo):
        # linux only
        pass

    def run_ansible(self, args, path):
        result = None
        try:
            command = 'ansible-playbook '
            command += args
            Log.info('CWD: ' + Utils.get_relative_path(str(path)))
            Log.cmd(command)
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout, shell=True)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
            return False
        return result.returncode == 0

    def run_docker_ansible(self, args, path, sudo):
        # Linux only
        pass

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

    def scp(self, source, destination, ssh_key, path):
        # scp files
        Log.info(f'Launch scp {source} -> {destination}')
        scp_command = f"scp -o StrictHostKeyChecking=no -i {ssh_key}"
        command = f'{scp_command} {source} {destination}'
        self.run_shell(command, path)

    def rsync(self, source, destination, ssh_key, exclude=True):
        # rsync = f'rsync -a --exclude-from='.gitignore' -e "ssh -o 'StrictHostKeyChecking no' -i $CURRENT_DIR/ad/$lab/providers/$provider/ssh_keys/ubuntu-jumpbox.pem" "$CURRENT_DIR/" goad@$public_ip:~/GOAD/'
        Log.info(f'Launch Rsync {source} -> {destination}')
        ssh_command = f"ssh -o StrictHostKeyChecking=no -i {ssh_key}"
        exclude_from = ''
        if exclude:
            exclude_from = '--exclude-from=".gitignore"'
        command = f'rsync -a {exclude_from} -e "{ssh_command}" {source} {destination}'
        self.run_shell(command, source)
