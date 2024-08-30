import os
import shutil
from goad.provider.provider import Provider
from goad.log import Log
from goad.utils import *


class VagrantProvider(Provider):

    def check(self):
        self.command.check_vagrant()

    def install(self):
        self.command.run_vagrant(['up'], self.path)

    def destroy(self):
        self.command.run_vagrant(['destroy'], self.path)

    def start(self):
        self.command.run_vagrant(['up'], self.path)

    def stop(self):
        self.command.run_vagrant(['halt'], self.path)

    def status(self):
        self.command.run_vagrant(['status'], self.path)

    def destroy_vm(self, vm_name):
        self.command.run_vagrant(['destroy', vm_name], self.path)

    def start_vm(self, vm_name):
        self.command.run_vagrant(['up', vm_name], self.path)

    def stop_vm(self, vm_name):
        self.command.run_vagrant(['halt', vm_name], self.path)

    def install_extension(self, extension):
        super().install_extension(extension)
        extension_name = extension.name
        extension_filename = extension_name + '.rb'
        provider_extension_file = get_extension_provider_path(extension_name, self.provider_name) + os.path.sep + extension_filename
        if os.path.isfile(provider_extension_file):
            Log.success(f'Found provider extension file : {provider_extension_file}')
            destination_file = get_providers_path(self.lab_name) + os.path.sep + self.provider_name + os.path.sep + 'extensions' + os.path.sep + extension_filename
            shutil.copy(provider_extension_file, destination_file)
            Log.success(f'Extension file {extension_filename} copied')
            Log.info('relaunch providing for the extension')
            self.install()
        else:
            Log.error(f'Extension file {extension_filename} not found')

    def remove_extension(self, extension_name):
        # TODO
        pass
