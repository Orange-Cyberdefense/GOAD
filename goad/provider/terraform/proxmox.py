from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class ProxmoxProvider(TerraformProvider):
    provider_name = PROXMOX
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_REMOTE]

    def check(self):
        check_disk = self.command.check_disk()
        check_ram = self.command.check_ram()
        check_ansible = self.command.check_ansible()
        check_gem_winrm = self.command.check_gem('winrm')
        check_gem_winrmfs = self.command.check_gem('winrm-fs')
        check_gem_winrme = self.command.check_gem('winrm-elevated')
        return check_disk and check_ram and check_ansible and check_gem_winrm and check_gem_winrmfs and check_gem_winrme
