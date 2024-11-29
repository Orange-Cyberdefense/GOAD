from goad.log import Log
from goad.utils import *
from goad.provisioner.ansible.ansible import Ansible


class LocalAnsibleProvisionerCmd(Ansible):
    provisioner_name = PROVISIONING_LOCAL

    def run_playbook(self, playbook, inventories, tries=3, timeout=30, playbook_path=None):
        if playbook_path is None:
            playbook_path = self.path

        Log.info(f'Run playbook : {playbook} with inventory file(s) : {", ".join(inventories)}')

        args = f'-i {" -i ".join(inventories)} {playbook}'

        run_complete = False
        nb_try = 0
        while not run_complete:
            nb_try += 1
            run_complete = self.command.run_ansible(args, playbook_path)
            if not run_complete and nb_try > tries:
                Log.error('3 fails abort.')
                break
        return run_complete
