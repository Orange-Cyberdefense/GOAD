from goad.provider.provider import Provider


class VagrantProvider(Provider):

    def check(self):
        checks = [
            self.command.check_vagrant(),
            self.command.check_disk(),
            self.command.check_ram(),
            self.command.check_ansible(),
            self.command.check_vagrant_plugin('vagrant-reload')
        ]
        return all(checks)

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
