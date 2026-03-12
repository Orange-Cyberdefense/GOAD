from goad.utils import *
from goad.dependencies import Dependencies

if Dependencies.vmware_enabled:
    from goad.provider.vagrant.vmware import VmwareProvider
if Dependencies.vmware_esxi_enabled:
    from goad.provider.vagrant.vmware_esxi import VmwareEsxiProvider
if Dependencies.virtualbox_enabled:
    from goad.provider.vagrant.virtualbox import VirtualboxProvider
if Dependencies.azure_enabled:
    from goad.provider.terraform.azure import AzureProvider
if Dependencies.aws_enabled:
    from goad.provider.terraform.aws import AwsProvider
if Dependencies.proxmox_enabled:
    from goad.provider.terraform.proxmox import ProxmoxProvider
if Dependencies.ludus_enabled:
    from goad.provider.ludus.ludus import LudusProvider


class ProviderFactory:

    @staticmethod
    def get_provider(provider_name, lab_name, config):
        provider = None
        if provider_name == VIRTUALBOX and Dependencies.virtualbox_enabled:
            provider = VirtualboxProvider(lab_name)
        elif provider_name == VMWARE and Dependencies.vmware_enabled:
            provider = VmwareProvider(lab_name)
        elif provider_name == VMWARE_ESXI and Dependencies.vmware_esxi_enabled:
            provider = VmwareEsxiProvider(lab_name)
        elif provider_name == PROXMOX and Dependencies.proxmox_enabled:
            provider = ProxmoxProvider(lab_name, config)
        elif provider_name == AZURE and Dependencies.azure_enabled:
            provider = AzureProvider(lab_name)
        elif provider_name == AWS and Dependencies.aws_enabled:
            provider = AwsProvider(lab_name, config)
        elif provider_name == LUDUS and Dependencies.ludus_enabled:
            provider = LudusProvider(lab_name, config)
        return provider
