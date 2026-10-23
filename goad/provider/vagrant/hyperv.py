from goad.provider.vagrant.vagrant import VagrantProvider
from goad.utils import *


class HypervProvider(VagrantProvider):
    provider_name = HYPERV
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_VM]

    def check(self):
        checks = [
            super().check(),
            self.command.check_hyperv(),
        ]
        return all(checks)
