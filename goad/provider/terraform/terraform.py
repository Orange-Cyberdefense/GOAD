from goad.provider.provider import Provider
import os
import shutil
from goad.goadpath import GoadPath
from goad.log import Log


class TerraformProvider(Provider):

    def check(self):
        checks = [
            self.command.check_terraform(),
            self.command.check_rsync()
        ]
        return all(checks)

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
