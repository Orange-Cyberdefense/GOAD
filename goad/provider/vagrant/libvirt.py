from goad.provider.vagrant.vagrant import VagrantProvider
from goad.utils import *


class LibvirtProvider(VagrantProvider):
    provider_name = LIBVIRT
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_VM]

    def check(self):
        checks = [
            super().check(),
            self.command.check_libvirt(),
            self.command.check_vagrant_plugin('vagrant-libvirt', False)
        ]
        return all(checks)
