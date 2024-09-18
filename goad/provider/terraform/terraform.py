from goad.provider.provider import Provider
import os
import shutil
from goad.goadpath import GoadPath
from goad.log import Log


class TerraformProvider(Provider):

    def check(self):
        check_tf = self.command.check_terraform()
        check_rsync = self.command.check_rsync()
        return check_tf and check_rsync

    def install(self):
        self.command.run_terraform(['init'], self.path)
        self.command.run_terraform(['plan'], self.path)
        return self.command.run_terraform(['apply'], self.path)

    def destroy(self):
        return self.command.run_terraform(['destroy'], self.path)

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
        provider_extension_file = GoadPath.get_extension_provider_path(extension_name, self.provider_name) + os.path.sep + extension_filename
        if os.path.isfile(provider_extension_file):
            Log.success(f'Found provider extension file : {provider_extension_file}')
            destination_file = GoadPath.get_lab_providers_path(self.lab_name) + os.path.sep + self.provider_name + os.path.sep + 'terraform' + os.path.sep + extension_filename
            shutil.copy(provider_extension_file, destination_file)
            Log.success(f'Extension file {extension_filename} copied')
            Log.info('relaunch providing for the extension')
            self.install()
        else:
            Log.error(f'Extension file {extension_filename} not found')
