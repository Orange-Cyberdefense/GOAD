from goad.provisioner.ansible.ansible import Ansible
from goad.utils import *

class DockerAnsibleProvisioner(Ansible):
    provisioner_name = PROVISIONING_DOCKER

    def run_playbook(self, playbook, inventories, tries=3, timeout=30):
        pass