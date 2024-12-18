from goad.provider.vagrant.vagrant import VagrantProvider
from goad.utils import *


class VmwareEsxiProvider(VagrantProvider):
    provider_name = VMWARE_ESXI
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_VM]

    def check(self):
        checks = [
            super().check(),
            self.command.check_vagrant_plugin('vagrant-vmware-esxi', True),
            self.command.check_vagrant_plugin('vagrant-env', True),
            self.command.check_ovftool()
        ]
        return all(checks)
