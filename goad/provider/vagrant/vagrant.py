from goad.provider.provider import Provider
from goad.log import Log


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
