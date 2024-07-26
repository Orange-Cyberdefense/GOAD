from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class AzureProvider(TerraformProvider):
    provider_name = AZURE
