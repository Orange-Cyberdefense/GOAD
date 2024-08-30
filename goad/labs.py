from goad.extension import Extension
from goad.utils import *
from goad.log import Log
from goad.exceptions import *
from goad.provider.terraform.azure import AzureProvider
from goad.provider.terraform.aws import AwsProvider
from goad.provider.terraform.proxmox import ProxmoxProvider
from goad.provider.vagrant.virtualbox import VirtualboxProvider
from goad.provider.vagrant.vmware import VmwareProvider


class Labs:
    def __init__(self):
        self.labs = {}
        for lab_name in Utils.list_folders(get_labs_path()):
            if lab_name != 'TEMPLATE':
                try:
                    self.labs[lab_name] = Lab(lab_name)
                except ProviderPathNotFound as e:
                    Log.warning(f'lab {lab_name} not loaded provider path not found')

    def get_lab(self, lab_name):
        if lab_name not in self.labs.keys():
            return None
        return self.labs[lab_name]

    def get_labs_list(self):
        return list(self.labs.values())


class Lab:
    def __init__(self, lab_name):
        self.lab_name = lab_name
        self.providers = {}
        self.extensions = {}
        try:
            self._load_providers(lab_name)
        except FileNotFoundError as e:
            raise ProviderPathNotFound(e)
        try:
            self._load_extensions(lab_name)
        except FileNotFoundError as e:
            # no extensions
            pass

    def _load_providers(self, lab_name):
        for provider_name in Utils.list_folders(get_providers_path(lab_name)):
            provider = None
            if provider_name == VIRTUALBOX:
                provider = VirtualboxProvider(lab_name)
            elif provider_name == VMWARE:
                provider = VmwareProvider(lab_name)
            elif provider_name == PROXMOX:
                provider = ProxmoxProvider(lab_name)
            elif provider_name == AZURE:
                provider = AzureProvider(lab_name)
            elif provider_name == AWS:
                provider = AwsProvider(lab_name)
            if provider is not None:
                self.providers[provider_name] = provider

    def _load_extensions(self, lab_name):
        for extension_name in Utils.list_folders(get_extensions_path()):
            self.extensions[extension_name] = Extension(extension_name)

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

    def get_list_extensions(self):
        return list(self.extensions.keys())
