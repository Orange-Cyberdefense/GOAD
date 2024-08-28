from goad.provider.provider import Provider
import os


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

    def ssh_jumpbox(self):
        pass
