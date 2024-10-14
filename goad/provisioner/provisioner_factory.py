from goad.utils import *
from goad.dependencies import Dependencies
from goad.jumpbox import JumpBox
from goad.local_jumpbox import LocalJumpBox

if Dependencies.provisioner_local_enabled:
    from goad.provisioner.ansible.local import LocalAnsibleProvisionerCmd
if Dependencies.provisioner_runner_enabled:
    from goad.provisioner.ansible.runner import LocalAnsibleProvisionerEmbed
if Dependencies.provisioner_remote_enabled:
    from goad.provisioner.ansible.remote import RemoteAnsibleProvisioner
if Dependencies.provisioner_docker_enabled:
    from goad.provisioner.ansible.docker import DockerAnsibleProvisionerCmd
if Dependencies.provisioner_vm_enabled:
    from goad.provisioner.ansible.vm import VmAnsibleProvisioner


class ProvisionerFactory:

    @staticmethod
    def get_provisioner(provisioner_name, instance, is_instance_creation):
        lab_name = instance.lab_name
        provider = instance.provider
        provisioner = None
        if provisioner_name == PROVISIONING_LOCAL and Dependencies.provisioner_local_enabled:
            provisioner = LocalAnsibleProvisionerCmd(lab_name, provider)
        elif provisioner_name == PROVISIONING_REMOTE and Dependencies.provisioner_remote_enabled:
            provisioner = RemoteAnsibleProvisioner(lab_name, provider)
            provisioner.jumpbox = JumpBox(instance, is_instance_creation)
        elif provisioner_name == PROVISIONING_RUNNER and Dependencies.provisioner_runner_enabled:
            provisioner = LocalAnsibleProvisionerEmbed(lab_name, provider)
        elif provisioner_name == PROVISIONING_DOCKER and Dependencies.provisioner_docker_enabled:
            provisioner = DockerAnsibleProvisionerCmd(lab_name, provider)
        elif provisioner_name == PROVISIONING_VM and Dependencies.provisioner_vm_enabled:
            provisioner = VmAnsibleProvisioner(lab_name, provider)
            provisioner.jumpbox = LocalJumpBox(instance, is_instance_creation)
        return provisioner
