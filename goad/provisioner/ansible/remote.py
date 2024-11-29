from goad.log import Log
from goad.provisioner.ansible.ansible import Ansible
from goad.utils import *


class RemoteAnsibleProvisioner(Ansible):
    provisioner_name = PROVISIONING_REMOTE
    use_jumpbox = True

    def __init__(self, lab_name, provider):
        super().__init__(lab_name, provider)
        self.jumpbox = None
        self.remote_project_path = '/home/goad/GOAD'

    def prepare_jumpbox(self, jumpbox_ip):
        if self.jumpbox is not None:
            self.jumpbox.ip = jumpbox_ip
            self.jumpbox.sync_sources()
            self.jumpbox.provision()
        else:
            Log.error('no jumpbox for provisioner')

    def sync_source_jumpbox(self):
        if self.jumpbox is not None:
            self.jumpbox.sync_sources()
        else:
            Log.error('no jumpbox for provisioner')

    def run(self, playbook=None):
        if self.jumpbox is None:
            Log.error('Jumpbox not set')
            return False
        return super().run(playbook)

    def run_playbook(self, playbook, inventories, tries=3, timeout=30, playbook_path=None):
        if playbook_path is None:
            playbook_path = self.remote_project_path + '/ansible/'
        else:
            playbook_path = Utils.transform_local_path_to_remote_path(playbook_path, self.remote_project_path)

        remote_inventories = []
        for inventory in inventories:
            remote_inventories.append(Utils.transform_local_path_to_remote_path(inventory, self.remote_project_path))
        command = f'/home/goad/.local/bin/ansible-playbook -i {" -i ".join(remote_inventories)} {playbook}'

        Log.info(f'Run playbook : {playbook} with inventory file(s) : {", ".join(remote_inventories)}')
        Log.cmd('command')

        run_complete = False
        nb_try = 0
        while not run_complete:
            nb_try += 1
            run_complete = self.jumpbox.run_command(command, playbook_path)

            if not run_complete and nb_try > tries:
                Log.error('3 fails abort.')
                break
        return run_complete
