import os
import shutil
from goad.provider.provider import Provider
from goad.log import Log
from goad.goadpath import GoadPath


class VagrantProvider(Provider):

    def check(self):
        return self.command.check_vagrant()

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
        # TODO
        pass
