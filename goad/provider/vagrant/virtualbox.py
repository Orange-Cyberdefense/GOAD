from goad.provider.vagrant.vagrant import VagrantProvider
from goad.utils import *


class VirtualboxProvider(VagrantProvider):
    provider_name = VIRTUALBOX
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER]

    def check(self):
        super_check = super().check()
        check_vbox = self.command.check_virtualbox()
        return super_check and check_vbox
