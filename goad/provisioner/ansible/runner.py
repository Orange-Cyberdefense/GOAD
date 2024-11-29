import time

import ansible_runner
from goad.utils import *
from goad.log import Log
from goad.provisioner.ansible.ansible import Ansible


class LocalAnsibleProvisionerEmbed(Ansible):
    provisioner_name = PROVISIONING_RUNNER

    def run_playbook(self, playbook, inventories, tries=3, timeout=30, playbook_path=None):
        if playbook_path is None:
            playbook_path = self.path
        Log.info(f'Run playbook : {playbook} with inventory file(s) : {", ".join(inventories)}')
        Log.cmd(f'ansible-playbook -i {" -i ".join(inventories)} {playbook}')

        run_complete = False
        runner_result = None
        nb_try = 0
        while not run_complete:
            nb_try += 1
            runner_result = ansible_runner.run(private_data_dir=self.path + 'private_data_dir',
                                               playbook=playbook_path + playbook,
                                               inventory=inventories)
            if len(runner_result.stats['ok'].keys()) >= 1:
                run_complete = True
            if len(runner_result.stats['dark'].keys()) >= 1:
                Log.error('Unreachable vm wait 30 sec and restart ansible')
                time.sleep(30)
                run_complete = False
            if len(runner_result.stats['failures'].keys()) >= 1:
                Log.error(f'Error during playbook iteration {str(nb_try)}, restart')
                run_complete = False
            if nb_try > tries:
                Log.error('3 fails abort.')
                break
        # print(runner_result.stats)
        return run_complete

