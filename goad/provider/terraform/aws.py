from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class AwsProvider(TerraformProvider):
    provider_name = AWS
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]

    def __init__(self, lab_name):
        super().__init__(lab_name)
        self.jumpbox_setup_script = 'setup_aws.sh'