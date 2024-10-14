from goad.provider.vagrant.vagrant import VagrantProvider
from goad.utils import *


class VirtualboxProvider(VagrantProvider):
    provider_name = VIRTUALBOX
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_VM]

    def check(self):
        checks = [
            super().check(),
            self.command.check_virtualbox(),
            self.command.check_vagrant_plugin('vagrant-vbguest', False)
        ]
        return all(checks)
