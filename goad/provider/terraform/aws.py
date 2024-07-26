from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class AwsProvider(TerraformProvider):
    provider_name = AWS
