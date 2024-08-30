import cmd
import argparse
from rich import print

from goad.config import Config
from goad.jumpbox import JumpBox
from goad.lab_manager import LabManager
from goad.menu import print_menu, print_logo
from goad.log import Log
from goad.utils import *
from goad.labs import *
from goad.infos import *


class Goad(cmd.Cmd):

    def __init__(self, args):
        super().__init__()
        # get the arguments
        self.args = args

        # Prepare all labs objects
        labs = Labs()
        # prepare config, read goad.ini and merge with args
        config = Config().merge_config(args)

        # prepare lab controller to manage labs
        self.lab_manager = LabManager().init(labs, config)

        # set current lab and provider
        self.refresh_prompt()

    def refresh_prompt(self):
        self.prompt = f"\n{self.lab_manager.get_current_lab_name()} @ {self.lab_manager.get_current_provider_name()} > "

    def default(self, line):
        print()

    def do_help(self, arg):
        print_menu(self.lab_manager)

    def do_exit(self, arg):
        print('bye')
        return True

    # main commands
    def do_status(self, arg):
        self.lab_manager.get_current_provider().status()

    def do_check(self, arg):
        self.lab_manager.get_current_provider().check()

    def do_install(self, arg):
        self.lab_manager.get_current_provider().install()

    def do_start(self, arg):
        self.lab_manager.get_current_provider().start()

    def do_start_vm(self, arg):
        if arg == '':
            Log.error('missing virtual machine name')
            Log.info('start_vm <vm>')
        else:
            self.lab_manager.get_current_provider().start_vm(arg)

    def do_stop(self, arg):
        self.lab_manager.get_current_provider().stop()

    def do_stop_vm(self, arg):
        if arg == '':
            Log.error('missing virtual machine name')
            Log.info('stop_vm <vm>')
        else:
            self.lab_manager.get_current_provider().stop_vm(arg)

    def do_destroy(self, arg):
        self.lab_manager.get_current_provider().destroy()

    def do_destroy_vm(self, arg):
        if arg == '':
            Log.error('missing virtual machine name')
            Log.info('destroy_vm <vm>')
        else:
            self.lab_manager.get_current_provider().destroy_vm(arg)

    def do_provide(self, arg):
        self.lab_manager.get_current_provider().install()

    def do_provision(self, arg):
        if arg == '':
            Log.error('missing playbook argument')
            Log.info('provision <playbook>')
        else:
            # run playbook
            self.lab_manager.get_current_provisioner().run(arg)

    def do_provision_lab(self, arg):
        self.lab_manager.get_current_provisioner().run()

    def do_provision_lab_from(self, arg):
        self.lab_manager.get_current_provisioner().run_from(arg)

    def do_prepare_jumpbox(self, arg):
        if self.lab_manager.get_current_provisioner().provisioner_name == 'ansible_remote':
            self.lab_manager.get_current_provisioner().prepare_jumpbox()
        else:
            Log.error('no remote provisioning')

    def do_show_config(self, arg):
        show_current_config(self.lab_manager)

    def do_ssh_jumpbox(self, arg):
        if self.lab_manager.get_current_provider().use_jumpbox:
            try:
                jump_box = JumpBox(self.lab_manager.get_current_lab_name(), self.lab_manager.get_current_provider())
                jump_box.ssh()
            except JumpBoxInitFailed as e:
                Log.error('Jumpbox retrieve connection info failed, abort')
        else:
            Log.error('No jump box for this provider')

    # configuration
    def do_set_lab(self, arg):
        """
        Change/Set the lab to use
        :param arg: lab name
        :return: void
        """
        if arg == '':
            Log.error('missing lab argument')
            Log.info('set_lab <lab>')
        else:
            try:
                if self.lab_manager.set_lab(arg):
                    Log.success(f'Lab {arg} loaded')
                    self.refresh_prompt()
            except ValueError as err:
                Log.error(err.args[0])
                Log.info('Available labs :')
                for lab in self.lab_manager.labs:
                    Log.info(f' - {lab}')

    def do_set_provider(self, arg):
        """
        Change/Set the provider to use
        :param arg: provider name
        :return: void
        """
        if arg == '':
            Log.error('missing provider argument')
            Log.info(f'set_provider <provider> (allowed values : {",".join(ALLOWED_PROVIDERS)})')
        else:
            try:
                if self.lab_manager.set_provider(arg):
                    Log.success(f'Provider {arg} loaded')
                    self.refresh_prompt()
                else:
                    Log.error(f'provider {arg} does not exist on lab {self.lab_manager.get_current_lab_name()}')
                    Log.info('Available Providers :')
                    for provider_name in self.lab_manager.get_lab_providers(self.lab_manager.get_current_lab_name()):
                        Log.info(f' - {provider_name}')
            except ValueError as err:
                Log.error(err.args[0])

    def do_set_provisioning_method(self, arg):
        if arg == '':
            Log.error('missing provisioner argument')
            Log.info(f'set_provisioner <provisioner> (allowed values : {",".join(ALLOWED_PROVISIONER)})')
        else:
            try:
                if self.lab_manager.set_provisioner(arg):
                    Log.success(f'Provisioner {arg} loaded')
                    self.refresh_prompt()
                else:
                    Log.error(f'provisioner {arg} does not exist on lab {self.lab_manager.get_current_lab_name()}')
                    Log.info(f'Available Provisioner : {",".join(ALLOWED_PROVISIONER)}')
            except ValueError as err:
                Log.error(err.args[0])

    def do_list_extensions(self, arg):
        print(self.lab_manager.get_current_lab().get_list_extensions())

    def do_install_extension(self, arg):
        if arg == '':
            Log.error('missing extension argument')
            Log.info(f'provision_extension <extension>')
        else:
            extension_name = arg
            extension = self.lab_manager.get_current_lab().get_extension(extension_name)
            if extension is not None:
                self.lab_manager.get_current_provider().install_extension(extension)
            else:
                Log.error(f'extension {extension_name} not found abort')

    def do_provision_extension(self, arg):
        if arg == '':
            Log.error('missing extension argument')
            Log.info(f'provision_extension <extension>')
        else:
            extension_name = arg
            extension = self.lab_manager.get_current_lab().get_extension(extension_name)
            if extension is not None:
                self.lab_manager.get_current_provisioner().run_extension(extension)
            else:
                Log.error(f'extension {extension_name} not found abort')

    def do_show_labs_providers(self, arg):
        show_labs_providers_table(self.lab_manager.get_labs())

    def do_show_list_providers(self, arg):
        show_labs_providers_list(self.lab_manager.get_labs())


def parse_args():
    parser = argparse.ArgumentParser(prog='goad.py',
                                     description='Description : goad lab management console.',
                                     epilog=show_help(), formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-t", "--task", help="task to do", required=False)
    parser.add_argument("-l", "--lab", help="lab to use", required=False)
    parser.add_argument("-p", "--provider", help="provider to use", required=False)
    parser.add_argument("-e", "--extensions", help="extensions to use", action='append', required=False)
    parser.add_argument("-m", "--method", help="deploy method to use", required=False)
    parser.add_argument("-a", "--ansible_only", help="run only ansible on install", action='store_true', required=False)
    parser.add_argument("-r", "--run_playbook", help="run ansible playbook", action='store_true', required=False)
    args = parser.parse_args()
    return args


def show_help():
    return '''
   python3 goad.py  -t <task> -l <lab> -p <provider> -m <method>

   Example :
   - Install GOAD on virtualbox : python3 goad.py -t install -l GOAD -p virtualbox
'''


if __name__ == '__main__':
    print_logo()
    args = parse_args()
    goad = Goad(args)

    if args is None or args.task != '':
        goad.cmdloop()
