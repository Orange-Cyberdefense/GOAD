import cmd
import argparse
import time
from goad.config import Config
from goad.jumpbox import JumpBox
from goad.lab_manager import LabManager
from goad.menu import print_menu, print_logo
from goad.labs import *
from goad.infos import *


class Goad(cmd.Cmd):

    def __init__(self, args):
        super().__init__()
        # get the arguments
        self.args = args
        # prepare config, read configuration file and merge with args
        config = Config().merge_config(args)
        # prepare lab controller to manage labs
        self.lab_manager = LabManager().init(config)

        if args.task == '' or args.task is None:
            Log.info('Start Loading default instance')
            # load instance marked as default only if no args are provided
            self.lab_manager.load_default_instance()

        self.welcome()
        # set current lab and provider
        self.refresh_prompt()

    def welcome(self):
        Log.info('lab instances :')
        # show instances tables
        self.lab_manager.lab_instances.show_instances(current_instance_id=self.lab_manager.get_current_instance_id())
        # show current configuration
        # self.lab_manager.show_settings()

    def refresh_prompt(self):
        if self.lab_manager.get_current_instance_id() == '':
            self.prompt = f"\n{self.lab_manager.inline_settings()} > "
        else:
            self.prompt = f"\n{self.lab_manager.inline_settings()} ({self.lab_manager.get_current_instance_id()}) > "

    def default(self, line):
        print()

    def do_help(self, arg):
        print_menu(self.lab_manager)

    def do_exit(self, arg):
        print('bye')
        return True

    # main commands
    def do_check(self, arg):
        self.lab_manager.check()

    def do_status(self, arg):
        self.lab_manager.get_current_instance().provider.status()

    def do_install(self, arg=''):
        self.do_create_instance()

    def do_start(self, arg=''):
        self.lab_manager.get_current_instance_provider().start()

    def do_start_vm(self, arg):
        if arg == '':
            Log.error('missing virtual machine name')
            Log.info('start_vm <vm>')
        else:
            self.lab_manager.get_current_instance_provider().start_vm(arg)

    def do_stop(self, arg=''):
        self.lab_manager.get_current_instance_provider().stop()

    def do_stop_vm(self, arg):
        if arg == '':
            Log.error('missing virtual machine name')
            Log.info('stop_vm <vm>')
        else:
            self.lab_manager.get_current_instance_provider().stop_vm(arg)

    def do_destroy(self, arg=''):
        self.lab_manager.get_current_instance_provider().destroy()

    def do_destroy_vm(self, arg):
        if arg == '':
            Log.error('missing virtual machine name')
            Log.info('destroy_vm <vm>')
        else:
            self.lab_manager.get_current_instance_provider().destroy_vm(arg)

    def do_provide(self, arg=''):
        result = self.lab_manager.get_current_instance_provider().install()
        if result:
            self.lab_manager.get_current_instance().set_status(PROVIDED)
        return result

    def do_provision(self, arg):
        if arg == '':
            Log.error('missing playbook argument')
            Log.info('provision <playbook>')
        else:
            start = time.time()
            # run playbook
            self.lab_manager.get_current_instance_provisioner().run(arg)
            time_provision = time.ctime(time.time() - start)[11:19]
            Log.info(f'Provisioned with {arg} in {time_provision}')

    def do_provision_lab(self, arg=''):
        start = time.time()
        provision_result = self.lab_manager.get_current_instance_provisioner().run()
        if provision_result:
            self.lab_manager.get_current_instance().set_status(READY)
            time_provision = time.ctime(time.time() - start)[11:19]
            Log.info(f'Lab successfully provisioned in {time_provision}')

    def do_provision_lab_from(self, arg):
        start = time.time()
        provision_result = self.lab_manager.get_current_instance_provisioner().run_from(arg)
        if provision_result:
            time_provision = time.ctime(time.time() - start)[11:19]
            Log.info(f'Provisioned from {arg} in {time_provision}')

    def do_sync_source_jumpbox(self, arg=''):
        if self.lab_manager.get_current_instance_provider().use_jumpbox:
            self.lab_manager.get_current_instance_provisioner().sync_source_jumpbox()

    def do_prepare_jumpbox(self, arg=''):
        if self.lab_manager.get_current_instance_provider().use_jumpbox:
            jumpbox_ip = self.lab_manager.get_current_instance_provider().get_jumpbox_ip()
            if jumpbox_ip is not None:
                self.lab_manager.get_current_instance_provisioner().prepare_jumpbox(jumpbox_ip)
            else:
                Log.error('cannot find jumpbox ip')

    def do_show_config(self, arg):
        self.lab_manager.show_settings()

    def do_ssh_jumpbox(self, arg):
        if self.lab_manager.get_current_instance_provider().use_jumpbox:
            try:
                jump_box = self.lab_manager.get_current_instance_provisioner().jumpbox
                jump_box.ssh()
            except JumpBoxInitFailed as e:
                Log.error('Jumpbox retrieve connection info failed, abort')
        else:
            Log.error('No jump box for this provider')

    def do_ssh_jumpbox_proxy(self, arg):
        if self.lab_manager.get_current_instance_provider().use_jumpbox:
            try:
                jump_box = self.lab_manager.get_current_instance_provisioner().jumpbox
                if arg.isnumeric() and 1024 < int(arg) <= 65535:
                    jump_box.ssh_proxy(arg)
                else:
                    Log.error(f'Port value invalid : {arg}')
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
                self.lab_manager.set_lab(arg)
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
                self.lab_manager.set_provider(arg)
                self.refresh_prompt()
            except ValueError as err:
                Log.error(err.args[0])

    def do_set_provisioning_method(self, arg):
        if arg == '':
            Log.error('missing provisioner argument')
            Log.info(f'set_provisioner <provisioner> (allowed values : {",".join(ALLOWED_PROVISIONER)})')
        else:
            try:
                self.lab_manager.set_provisioner(arg)
                self.refresh_prompt()
            except ValueError as err:
                Log.error(err.args[0])

    def do_set_ip_range(self, arg):
        if arg == '':
            Log.error('missing ip_start argument')
            Log.info(f'set_ip_start <ip_start>')
        else:
            self.lab_manager.set_ip_range(arg)
            self.refresh_prompt()

    def do_list_extensions(self, arg):
        print(self.lab_manager.get_current_instance_lab().get_list_extensions())

    def do_install_extension(self, arg):
        if arg == '':
            Log.error('missing extension argument')
            Log.info(f'provision_extension <extension>')
        else:
            Log.info('start install extension')
            if self.lab_manager.current_instance is not None:
                extension_name = arg
                extension = self.lab_manager.get_current_instance_lab().get_extension(extension_name)
                if extension is not None:
                    # enable and create files
                    self.lab_manager.get_current_instance().enable_extension(extension_name)
                    # # start lab with extensions files (vagrant up / terraform plan)
                    self.lab_manager.get_current_instance_provider().install()
                    # # provision extension
                    self.do_provision_extension(extension_name)
                else:
                    Log.error(f'extension {extension_name} not found abort')
            else:
                Log.error('Install extension can only be run from an instance')

    def do_provision_extension(self, arg):
        if arg == '':
            Log.error('missing extension argument')
            Log.info(f'provision_extension <extension>')
        else:
            extension_name = arg
            if extension_name in self.lab_manager.get_current_instance().extensions:
                self.do_sync_source_jumpbox()
                extension = self.lab_manager.get_current_instance_lab().get_extension(extension_name)
                self.lab_manager.get_current_instance_provisioner().run_extension(extension)
            else:
                Log.error(f'extension {extension_name} not enabled in instance abort')

    def do_show_labs_providers(self, arg):
        show_labs_providers_table(self.lab_manager.get_labs())

    def do_show_list_providers(self, arg):
        show_labs_providers_list(self.lab_manager.get_labs())

    def do_update_instance_files(self, arg):
        self.lab_manager.update_instance_files()

    def do_create_instance(self, arg=''):
        Log.info('Create instance folder')
        self.lab_manager.create_instance()
        Log.info('Launch providing')
        if self.do_provide():
            Log.info('Prepare jumpbox if needed')
            self.do_prepare_jumpbox()
            Log.info('Launch provisioning')
            self.do_provision_lab()
            self.refresh_prompt()
        else:
            Log.error('Providing error stop')

    def do_create_empty_instance(self, arg=''):
        Log.info('Create instance folder')
        self.lab_manager.create_instance()

    def do_set_as_default(self, arg):
        self.lab_manager.set_as_default_instance()

    def do_load_instance(self, arg):
        if arg == '':
            Log.error('missing instance id argument')
            Log.info(f'use_instance <instance_id>')
        else:
            self.lab_manager.load_instance(arg)
            if self.lab_manager.current_instance is not None:
                self.lab_manager.lab_instances.show_instances(current_instance_id=self.lab_manager.get_current_instance_id(), filter_instance_id=self.lab_manager.get_current_instance_id())
            self.refresh_prompt()

    def do_unload_instance(self, arg):
        if self.lab_manager.get_current_instance_id() is not None:
            self.lab_manager.unload_instance()
            self.refresh_prompt()

    def do_list_instances(self, arg):
        self.lab_manager.lab_instances.show_instances(current_instance_id=self.lab_manager.get_current_instance_id())


def parse_args():
    parser = argparse.ArgumentParser(prog='goad.py',
                                     description='Description : goad lab management console.',
                                     epilog=show_help(), formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-t", "--task", help="task to do", required=False)
    parser.add_argument("-l", "--lab", help="lab to use (default: GOAD)", default='GOAD', required=False)
    parser.add_argument("-p", "--provider", help="provider to use (default: vmware)", default='vmware', required=False)
    parser.add_argument("-ip", "--ip_range", help="ip range to use (default: 192.168.56)", default='192.168.56', required=False)
    parser.add_argument("-m", "--method", help="deploy method to use (default: local)", default='local', required=False)
    parser.add_argument("-e", "--extensions", help="extensions to use", action='append', required=False)
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

    # Command line args like the old goad.sh commands
    if args.task != '':
        if args.task == 'install':
            goad.do_install()
        elif args.task == 'check':
            goad.do_check()
        elif args.task == 'start':
            goad.do_start()
        elif args.task == 'stop':
            goad.do_stop()
        elif args.task == 'restart':
            goad.do_stop()
            goad.do_start()
        elif args.task == 'destroy':
            goad.do_destroy()
        elif args.task == 'status':
            goad.do_status()
