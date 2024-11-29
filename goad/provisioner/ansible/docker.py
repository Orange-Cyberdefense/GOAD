from goad.log import Log
from goad.utils import *
from goad.goadpath import GoadPath
from goad.provisioner.ansible.ansible import Ansible
import subprocess
import os


class DockerAnsibleProvisionerCmd(Ansible):
    provisioner_name = 'docker'

    def __init__(self, lab_name, provider):
        super().__init__(lab_name, provider)
        self.remote_project_path = '/goad'
        if self.is_current_user_in_docker_group():
            self.sudo = ''
        else:
            self.sudo = 'sudo'
        self.check_docker_image()

    def is_current_user_in_docker_group(self):
        try:
            # Get the current logged-in user
            user = os.getlogin()
            # Run the 'groups' command to get the groups the user belongs to
            output = subprocess.check_output(['groups', user], text=True)
            # Check if 'sudo' is in the output
            if 'docker' in output.split():
                Log.info('Current user is in docker group')
                return True
            else:
                Log.info('Current user is not in docker group, we will use "sudo" before docker commands')
                return False
        except subprocess.CalledProcessError:
            # If the command fails, return False
            return False

    def check_docker_image(self):
        if not self.command.run_command(f'{self.sudo} docker images |grep -c "goadansible"', GoadPath.get_project_path()):
            Log.error('Docker image goadansible not found')
            Log.info('You should build the docker image with : "sudo docker build -t goadansible ."')
        else:
            Log.success('Docker image exist')

    def run_playbook(self, playbook, inventories, tries=3, timeout=30, playbook_path=None):
        remote_inventories = []
        for inventory in inventories:
            remote_inventories.append(Utils.transform_local_path_to_remote_path(inventory, self.remote_project_path))
        command = f'-i {" -i ".join(remote_inventories)} {playbook}'
        Log.info(f'Run playbook : {playbook} with inventory file(s) : {", ".join(remote_inventories)}')
        run_complete = False
        nb_try = 0
        if playbook_path is not None:
            ansible_path = Utils.transform_local_path_to_remote_path(playbook_path, self.remote_project_path)
        else:
            ansible_path = '/goad/ansible'
        while not run_complete:
            nb_try += 1
            run_complete = self.command.run_docker_ansible(command, GoadPath.get_project_path(), ansible_path, self.sudo)
            if not run_complete and nb_try > tries:
                Log.error('3 fails abort.')
                break
        return run_complete
