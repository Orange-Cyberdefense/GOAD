from rich import print
from goad.utils import *

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


def print_menu_title(title):
    print()
    print(f'[cyan3]*** {title} ***[/cyan3]')


def print_menu_entry(cmd, description):
    line = f'{cmd} [white]'.ljust(48, '.')
    print(f'{line}[/white] [sky_blue3]{description}[/sky_blue3]')


def print_menu(lab_manager):
    provider = lab_manager.get_current_provider_name()

    print_menu_title('Installation commands')
    print_menu_entry('check', 'check dependencies for install')
    print_menu_entry('install', 'launch install (provide + provision_lab)')

    print_menu_title('Manage commands')
    print_menu_entry('status', 'show current status')
    print_menu_entry('start', 'start lab')
    print_menu_entry('stop', 'stop lab')
    print_menu_entry('destroy', 'destroy lab')

    print_menu_title('Configuration')
    print_menu_entry('show_config', 'show current configuration')
    print_menu_entry('set_lab <lab>', 'change the lab to use')
    print_menu_entry('set_provider <provider>', 'change the provider to use')
    print_menu_entry('set_provisioning_method <method>', 'change the provisioning method')

    print_menu_title('Providing (Vagrant/Terrafom)')
    print_menu_entry('provide', 'run only the providing (vagrant/terraform)')

    if provider == AZURE or provider == AWS:
        print_menu_title('JumpBox')
        print_menu_entry('prepare_jumpbox', 'install package on the jumpbox for provisioning')
        print_menu_entry('ssh_jumpbox', 'connect to jump box with ssh')

    print_menu_title('Provisioning (Ansible)')
    print_menu_entry('provision <playbook>', 'run specific ansible playbook')
    print_menu_entry('provision_lab', 'run all the current lab ansible playbooks')
    print_menu_entry('provision_lab_from <playbook>', 'run all the current lab ansible playbooks from specific playbook to the end')

    print_menu_title('Global commands')
    print_menu_entry('show_providers_table', 'show all labs and availble providers')
