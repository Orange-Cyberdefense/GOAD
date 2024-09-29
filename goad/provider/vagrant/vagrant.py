import os
import shutil
from goad.provider.provider import Provider
from goad.log import Log
from goad.goadpath import GoadPath


class VagrantProvider(Provider):

    def check(self):
        check_vagrant = self.command.check_vagrant()
        check_disk = self.command.check_disk()
        check_ram = self.command.check_ram()
        check_ansible = self.command.check_ansible()
        check_vagrant_reload = self.command.check_vagrant_plugin('vagrant-reload')
        check_gem_winrm = self.command.check_gem('winrm')
        check_gem_winrmfs = self.command.check_gem('winrm-fs')
        check_gem_winrme = self.command.check_gem('winrm-elevated')
        return check_vagrant and check_disk and check_ram and check_ansible and check_vagrant_reload and check_gem_winrm and check_gem_winrmfs and check_gem_winrme

    def install(self):
        return self.command.run_vagrant(['up'], self.path)

    def destroy(self):
        return self.command.run_vagrant(['destroy'], self.path)

    def start(self):
        return self.command.run_vagrant(['up'], self.path)

    def stop(self):
        return self.command.run_vagrant(['halt'], self.path)

    def status(self):
        return self.command.run_vagrant(['status'], self.path)

    def destroy_vm(self, vm_name):
        return self.command.run_vagrant(['destroy', vm_name], self.path)

    def start_vm(self, vm_name):
        return self.command.run_vagrant(['up', vm_name], self.path)

    def stop_vm(self, vm_name):
        return self.command.run_vagrant(['halt', vm_name], self.path)

    def remove_extension(self, extension_name):
        # TODO one day if possible
        pass
