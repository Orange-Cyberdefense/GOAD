import cmd
import argparse
from rich import print

from goad.config import Config
from goad.lab_controller import LabController
from goad.menu import print_menu
from goad.log import Log
from goad.utils import *
from goad.labs import *
from goad.gui import *


class Goad(cmd.Cmd):

    @staticmethod
    def print_logo():
        logo = """[white]
   _____   _____          _____ 
  / ____| / ||| \  [blue] /\\\\[/blue]   |  __ \ 
 | |  __||  |||  | [blue]/  \\\\[/blue]  | |  | |
 | | |_ ||  |||  |[blue]/ /\ \\\\[/blue] | |  | |
 | |__| ||  |||  [blue]/ /__\ \\\\[/blue]| |__| |
  \_____| \_|||_[blue]/________\\\\[/blue]_____/
    [bold]Game Of Active Directory[/bold]
      [yellow][italic]Pwning is comming[/italic][/yellow]
[/white]
Goad management console type help or ? to list commands
"""
        print(logo)

    def __init__(self, args):
        super().__init__()
        # get the arguments
        self.args = args

        # Prepare all labs objects
        labs = Labs()
        # prepare config, read goad.ini and merge with args
        config = Config().merge_config(args)

        # prepare lab controller to manage labs
        self.lab_controller = LabController().init(labs, config)

        # set current lab and provider
        self.refresh_prompt()

    def refresh_prompt(self):
        self.prompt = f"\n{self.lab_controller.get_current_lab_name()} @ {self.lab_controller.get_current_provider_name()} > "

    def default(self, line):
        print()

    def do_help(self, arg):
        print_menu()

    def do_exit(self, arg):
        print('bye')
        return True

    # main commands
    def do_status(self, arg):
        self.lab_controller.get_current_provider().status()

    def do_check(self, arg):
        self.lab_controller.get_current_provider().check()

    def do_install(self, arg):
        self.lab_controller.get_current_provider().install()

    def do_start(self, arg):
        self.lab_controller.get_current_provider().start()

    def do_stop(self, arg):
        self.lab_controller.get_current_provider().stop()

    def do_destroy(self, arg):
        self.lab_controller.get_current_provider().destroy()

    def do_lab_info(self, arg):
        pass

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
                if self.lab_controller.set_lab(arg):
                    Log.success(f'Lab {arg} loaded')
                    # lab has changed, so change the provider too
                    self.do_set_provider(self.lab_controller.get_current_provider_name())
                    self.refresh_prompt()
            except ValueError as err:
                Log.error(err.args[0])
                Log.info('Available labs :')
                for lab in self.lab_controller.labs:
                    Log.info(f' - {lab}')

    def do_set_provider(self, arg):
        """
        Change/Set the provider to use
        :param arg: provider name
        :return: void
        """
        if arg == '':
            Log.error('missing provider argument')
            Log.info('set_provider <provider>')
        else:
            try:
                if self.lab_controller.set_provider(arg):
                    Log.success(f'Provider {arg} loaded')
                    self.refresh_prompt()
                else:
                    Log.error(f'provider {arg} does not exist on lab {self.lab_controller.get_current_lab_name()}')
                    Log.info('Available Providers :')
                    for provider_name in self.lab_controller.get_lab_providers(self.lab_controller.get_current_lab_name()):
                        Log.info(f' - {provider_name}')
            except ValueError as err:
                Log.error(err.args[0])

    # def do_show_config(self, arg):
    #     self.config.show_config()

    def do_show_table_providers(self, arg):
        show_labs_providers(self.lab_controller.get_labs())

    def do_show_list_providers(self, arg):
        for lab in self.lab_controller.get_labs():
            Log.success(f'*** {lab.lab_name} ***')
            for provider in lab.providers.keys():
                Log.info(f' {provider}')


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
    Goad.print_logo()
    args = parse_args()
    goad = Goad(args)

    if args is None or args.task != '':
        goad.cmdloop()
