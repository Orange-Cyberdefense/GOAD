from rich import print


def print_menu_title(title):
    print()
    print(f'[cyan3]*** {title} ***[/cyan3]')


def print_menu_entry(cmd, description):
    line = f'{cmd} [white]'.ljust(48, '.')
    print(f'{line}[/white] [sky_blue3]{description}[/sky_blue3]')


def print_menu():
    print_menu_title('Main commands')
    print_menu_entry('status', 'show current status')
    print_menu_entry('check', 'check dependencies for install')
    print_menu_entry('install', 'launch install')
    print_menu_entry('start', 'start lab')
    print_menu_entry('stop', 'stop lab')
    print_menu_entry('destroy', 'destroy lab')
    print_menu_entry('lab_info', 'display lab infos')

    print_menu_title('Configuration')
    print_menu_entry('show_config', 'show current configuration')
    print_menu_entry('set_lab <lab>', 'change the lab to use')
    print_menu_entry('set_provider <provider>', 'change the provider to use')
    print_menu_entry('set_method <method>', 'change the provisioning method')

    print_menu_title('Providing (Vagrant/Terrafom)')
    print_menu_entry('create', 'run only the providing (vagrant/terraform)')

    print_menu_title('Provisioning (Ansible)')
    print_menu_entry('run <playbook>', 'run specific ansible playbook')
    print_menu_entry('run_all', 'run all the current lab ansible playbooks')

    print_menu_title('Global commands')
    print_menu_entry('global_status', 'show all lab status')
