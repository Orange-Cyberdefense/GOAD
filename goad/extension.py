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

    def get_inventory(self, provider_name):
        inventory = []
        # main inventory (inside ansible folder)
        extension_inventory = get_extension_inventory_path(self.name)
        if os.path.isfile(extension_inventory):
            inventory.append(extension_inventory)
            Log.success(f'Extension inventory : {extension_inventory} file found')

        # extension provider inventory
        if provider_name in self.providers_name_list:
            extension_provider_inventory = get_extension_provider_inventory_path(self.name, provider_name)
            if os.path.isfile(extension_provider_inventory):
                inventory.append(extension_provider_inventory)
                Log.success(f'Extension provider inventory : {extension_provider_inventory} file found')

        return inventory

    def get_playbook(self, install=True):
        if install:
            return 'install.yml'
        else:
            return 'uninstall.yml'

    def get_ansible_path(self):
        return get_extension_ansible_path(self.name)
