from goad.provider.vagrant.vagrant import VagrantProvider
from goad.utils import *


class VmwareProvider(VagrantProvider):
    provider_name = VMWARE
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = VMWARE_ALLOWED_PROVISIONER

    def check(self):
        super_check = super().check()
        check_vmware = self.command.check_vmware()
        check_vagrant_plugin = self.command.check_vagrant_plugin('vagrant-vmware-desktop')
        return super_check and check_vmware and check_vagrant_plugin
