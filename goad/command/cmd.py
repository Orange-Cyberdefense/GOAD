class Command:

    def is_in_path(self, bin_file):
        pass

    def run(self, cmd, args, path):
        pass

    def check_vagrant(self):
        pass

    def check_vmware(self):
        pass

    def run_vagrant(self, args, path):
        pass

    def check_terraform(self):
        pass

    def run_terraform(self, args, path):
        pass

    def run_terraform_output(self, args, path):
        pass

    def run_ansible(self, args, path):
        pass

    def get_azure_account_output(self):
        pass
