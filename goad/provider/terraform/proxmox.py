from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class ProxmoxProvider(TerraformProvider):
    provider_name = PROXMOX
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_REMOTE]
