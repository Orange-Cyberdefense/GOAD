from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class ProxmoxProvider(TerraformProvider):
    provider_name = PROXMOX
