from goad.log import Log
from goad.utils import *
from goad.goadpath import GoadPath
from goad.provisioner.ansible.ansible import Ansible


class DockerAnsibleProvisionerCmd(Ansible):
    provisioner_name = 'docker'

    def __init__(self, lab_name, provider):
        super().__init__(lab_name, provider)
        self.remote_project_path = '/goad'
        self.sudo = 'sudo'
        self.check_docker_image()

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
        while not run_complete:
            nb_try += 1
            run_complete = self.command.run_docker_ansible(command, GoadPath.get_project_path(), self.sudo)
            if not run_complete and nb_try > tries:
                Log.error('3 fails abort.')
                break
        return run_complete
