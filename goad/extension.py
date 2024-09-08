from goad.utils import *
from goad.log import Log
from goad.goadpath import GoadPath


class Extension:

    def __init__(self, extension_name):
        self.name = extension_name
        self.providers_name_list = self.load_extension_providers(extension_name)

    def load_extension_providers(self, extension_name):
        providers_name_list = []
        for provider_name in Utils.list_folders(GoadPath.get_extension_providers_path(extension_name)):
            if provider_name in ALLOWED_PROVIDERS:
                providers_name_list.append(provider_name)
        return providers_name_list

    def list_providers_name(self):
        return self.providers_name_list

    def get_playbook(self, install=True):
        if install:
            return 'install.yml'
        else:
            return 'uninstall.yml'

    def get_ansible_path(self):
        return GoadPath.get_extension_ansible_path(self.name)
