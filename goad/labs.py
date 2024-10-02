from goad.extension import Extension
from goad.utils import *
from goad.goadpath import GoadPath
from goad.log import Log
from goad.exceptions import *
from goad.dependencies import *

if vmware_enabled:
    from goad.provider.vagrant.vmware import VmwareProvider
if virtualbox_enabled:
    from goad.provider.vagrant.virtualbox import VirtualboxProvider
if azure_enabled:
    from goad.provider.terraform.azure import AzureProvider
if aws_enabled:
    from goad.provider.terraform.aws import AwsProvider
if proxmox_enabled:
    from goad.provider.terraform.proxmox import ProxmoxProvider
if ludus_enabled:
    from goad.provider.ludus.ludus import LudusProvider


class Labs:
    def __init__(self, config):
        self.labs = {}
        for lab_name in Utils.list_folders(GoadPath.get_labs_path()):
            if lab_name != 'TEMPLATE':
                try:
                    self.labs[lab_name] = Lab(lab_name, config)
                except ProviderPathNotFound as e:
                    Log.warning(f'lab {lab_name} not loaded provider path not found')

    def get_lab(self, lab_name):
        if lab_name not in self.labs.keys():
            return None
        return self.labs[lab_name]

    def get_labs_list(self):
        return list(self.labs.values())

    def is_exist(self, lab_name):
        return lab_name in self.labs.keys()


class Lab:
    def __init__(self, lab_name, config):
        self.lab_name = lab_name
        self.providers = {}
        self.extensions = {}
        try:
            self._load_providers(lab_name, config)
        except FileNotFoundError as e:
            raise ProviderPathNotFound(e)
        try:
            self._load_extensions(lab_name)
        except FileNotFoundError as e:
            # no extensions
            pass

    def _load_providers(self, lab_name, config):
        for provider_name in Utils.list_folders(GoadPath.get_lab_providers_path(lab_name)):
            provider = None
            if provider_name == VIRTUALBOX and virtualbox_enabled:
                provider = VirtualboxProvider(lab_name)
            elif provider_name == VMWARE and vmware_enabled:
                provider = VmwareProvider(lab_name)
            elif provider_name == PROXMOX and proxmox_enabled:
                provider = ProxmoxProvider(lab_name, config)
            elif provider_name == AZURE and azure_enabled:
                provider = AzureProvider(lab_name)
            elif provider_name == AWS and aws_enabled:
                provider = AwsProvider(lab_name, config)
            elif provider_name == LUDUS and ludus_enabled:
                provider = LudusProvider(lab_name, config)
            if provider is not None:
                self.providers[provider_name] = provider

    def _load_extensions(self, lab_name):
        for extension_name in Utils.list_folders(GoadPath.get_extensions_path()):
            extension = Extension(extension_name)
            if extension.is_available(lab_name):
                self.extensions[extension_name] = extension

    def get_provider(self, provider_name):
        if provider_name not in self.providers.keys():
            return None
        return self.providers[provider_name]

    def get_first_provider_name(self):
        return next(iter(self.providers))

    def get_extension(self, extension_name):
        if extension_name in self.extensions.keys():
            return self.extensions[extension_name]
        else:
            return None

    def get_list_extensions_name(self):
        return list(self.extensions.keys())

    def show_extensions(self):
        for extension_name in self.extensions.keys():
            self.extensions[extension_name].show()
