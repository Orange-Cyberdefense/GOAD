from goad.provider.provider import Provider
import os
import shutil
from goad.utils import *
from goad.log import Log


class TerraformProvider(Provider):

    def __init__(self, lab_name):
        super().__init__(lab_name)
        self.path = self.path + 'terraform' + os.path.sep

    def check(self):
        self.command.check_terraform()

    def install(self):
        self.command.run_terraform(['init'], self.path)
        self.command.run_terraform(['plan'], self.path)
        self.command.run_terraform(['apply'], self.path)

    def destroy(self):
        self.command.run_terraform(['destroy'], self.path)

    def start(self):
        pass

    def stop(self):
        pass

    def status(self):
        pass

    def start_vm(self, vm_name):
        pass

    def stop_vm(self, vm_name):
        pass

    def destroy_vm(self, vm_name):
        pass

    def ssh_jumpbox(self):
        pass

    def install_extension(self, extension):
        super().install_extension(extension)
        extension_name = extension.name
        extension_filename = extension_name + '.tf'
        provider_extension_file = get_extension_provider_path(extension_name, self.provider_name) + os.path.sep + extension_filename
        if os.path.isfile(provider_extension_file):
            Log.success(f'Found provider extension file : {provider_extension_file}')
            destination_file = get_providers_path(self.lab_name) + os.path.sep + self.provider_name + os.path.sep + 'terraform' + os.path.sep + extension_filename
            shutil.copy(provider_extension_file, destination_file)
            Log.success(f'Extension file {extension_filename} copied')
            Log.info('relaunch providing for the extension')
            self.install()
        else:
            Log.error(f'Extension file {extension_filename} not found')
