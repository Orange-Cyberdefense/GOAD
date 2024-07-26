from goad.provider.provider import Provider


class TerraformProvider(Provider):

    def check(self):
        self.command.check_terraform()

    def dependencies(self):
        pass

    def install(self):
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
