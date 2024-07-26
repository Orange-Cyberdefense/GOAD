import sys

from goad.command.cmd import Command
import subprocess
from goad.log import Log


class LinuxCommand(Command):

    def check_vagrant(self):
        command = 'which vagrant >/dev/null'
        try:
            subprocess.run(command, shell=True, check=True)
            Log.success('vagrant found in PATH')
            return True
        except subprocess.CalledProcessError as e:
            Log.error('vagrant not found in PATH')
            return False

    def run_vagrant(self, args, path):
        result = None
        try:
            command = ['vagrant']
            command += args
            Log.info('CWD: ' + str(path))
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
            Log.info('CWD: ' + str(path))
            Log.cmd(' '.join(command))
            result = subprocess.run(command, cwd=path, stderr=sys.stderr, stdout=sys.stdout)
        except subprocess.CalledProcessError as e:
            Log.error(f"An error occurred while running the command: {e}")
        return result

    def run_ansible(self, args, path):
        pass

    def run_bash_script(self, args, path):
        pass