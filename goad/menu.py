from rich import print
from goad.utils import *


def print_logo():
    logo = """[white]
   _____   _____          _____ 
  / ____| / ||| \\  [blue] /\\\\[/blue]   |  __ \\ 
 | |  __||  |||  | [blue]/  \\\\[/blue]  | |  | |
 | | |_ ||  |||  |[blue]/ /\\ \\\\[/blue] | |  | |
 | |__| ||  |||  [blue]/ /__\\ \\\\[/blue]| |__| |
  \\_____| \\_|||_[blue]/________\\\\[/blue]_____/
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


def print_menu(lab_manager, advanced=True, debug=False):
    provider = lab_manager.get_current_provider_name()

    if lab_manager.get_current_instance() is not None:
        use_jumpbox = lab_manager.get_current_instance_provisioner().use_jumpbox
        print_menu_title('Manage Lab instance commands')
        print_menu_entry('status', 'show current status')
        print_menu_entry('start', 'start lab')
        print_menu_entry('stop', 'stop lab')
        print_menu_entry('destroy', 'destroy lab')
        if lab_manager.get_current_instance().is_vagrant():
            print_menu_entry('snapshot', 'snapshot lab')
            print_menu_entry('reset', 'revert lab to last snapshot')

        print_menu_title('Manage one vm commands')
        print_menu_entry('start_vm <vm_name>', 'start selected virtual machine')
        print_menu_entry('stop_vm <vm_name>', 'stop selected virtual machine')
        print_menu_entry('restart_vm <vm_name>', 'restart selected virtual machine')
        print_menu_entry('destroy_vm <vm_name>', 'destroy selected virtual machine')

        print_menu_title('Extensions')
        print_menu_entry('list_extensions', 'list extensions')
        print_menu_entry('install_extension <extension>', 'install extension (providing + provisioning)')

        if advanced:
            print_menu_entry('provision_extension <extension>', 'provision extension (provisioning only)')

        if use_jumpbox:
            print_menu_title('JumpBox')
            if advanced:
                print_menu_entry('prepare_jumpbox', 'install package on the jumpbox for provisioning')
                print_menu_entry('sync_source_jumpbox', 'sync source of the jumpbox')
            print_menu_entry('ssh_jumpbox', 'connect to jump box with ssh')
            print_menu_entry('ssh_jumpbox_proxy <proxy_port>', 'connect to jump box with ssh and start a socks proxy')

        if advanced:
            print_menu_title('Providing (Vagrant/Terrafom)')
            print_menu_entry('provide', 'run only the providing (vagrant/terraform)')

            print_menu_title('Provisioning (Ansible)')
            print_menu_entry('provision <playbook>', 'run specific ansible playbook')
            print_menu_entry('provision_lab', 'run all the current lab ansible playbooks')
            print_menu_entry('provision_lab_from <playbook>', 'run all the current lab ansible playbooks from specific playbook to the end')

    print_menu_title('Lab Instances')
    print_menu_entry('check', 'check dependencies before creation')
    if lab_manager.get_current_instance() is None:
        print_menu_entry('install / create', 'install the selected lab and create a lab instance')
        print_menu_entry('create_empty', 'prepare a lab instance folder without providing and provisioning')
    if lab_manager.get_current_instance() is not None:
        print_menu_entry('install', 'install the current instance (provide + prepare_jumpbox + provision_lab')
        print_menu_entry('set_as_default', 'set instance as default')
        print_menu_entry('update_instance_files', 'update lab instance files')
        if provider != AZURE and provider != AWS:
            print_menu_entry('disable_vagrant', 'disable vagrant user')
            print_menu_entry('enable_vagrant', 'enable vagrant user')
    print_menu_entry('list', 'list lab instances')
    print_menu_entry('load <instance_id>', 'load a lab instance')

    print_menu_title('Configuration')
    print_menu_entry('config', 'show current configuration')
    if lab_manager.get_current_instance() is None:
        print_menu_entry('labs', 'show all labs and available providers')
        print_menu_entry('set_lab <lab>', 'set the lab to use')
        print_menu_entry('set_provider <provider>', 'set the provider to use')
        print_menu_entry('set_provisioning_method <method>', 'set the provisioning method')
        print_menu_entry('set_ip_range <range>', 'set the 3 first digit of the ip to use (ex: 192.168.56)')

    if lab_manager.get_current_instance() is not None:
        print_menu_entry('unload', 'unload current instance')
        print_menu_entry('delete', 'delete the currently selected lab instance')
