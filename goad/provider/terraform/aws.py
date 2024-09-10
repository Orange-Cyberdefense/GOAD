from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *
from goad.log import Log


class AwsProvider(TerraformProvider):
    provider_name = AWS
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]
    use_jumpbox = True

    def __init__(self, lab_name):
        super().__init__(lab_name)
        self.jumpbox_setup_script = 'setup_aws.sh'
        self.tag = lab_name

    def set_tag(self, tag):
        # tag should be <instance_id>-<LAB>
        self.tag = tag

    def get_jumpbox_ip(self):
        jumpbox_ip = self.command.run_terraform_output(['ubuntu-jumpbox-ip'], self.path)
        if jumpbox_ip is None:
            Log.error('Jump box ip not found')
            return None
        if not Utils.is_valid_ipv4(jumpbox_ip):
            Log.error('Invalid IP')
            return None
        return jumpbox_ip
