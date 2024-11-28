# Add a new provider

🚧 TODO TO BE COMPLETED

## Provider files
- Add the new provider files in each lab location : `ad/<lab>/providers/<provider_name>`
- Add the new provider files in each extension location : `extensions/<extension>/providers/<provider_name>`
- Create the provider templates file in : `template/provider/<provider_name>`

## Provider python class
- Create the new provider class in `goad/provider/`

- If you use vagrant :
    - create the new provider in `goad/provider/vagrant/myprovider.py`
```python
from goad.provider.vagrant.vagrant import VagrantProvider
from goad.utils import *


class MyProviderProvider(VagrantProvider):
    provider_name = MYPROVIDER
    default_provisioner = PROVISIONING_LOCAL
    # define the provisioner allowed
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER, PROVISIONING_VM]

    def check(self):
        checks = [
            super().check(),
            self.command.check_myprovider(),
            # self.command.check_vagrant_plugin('myvagrant_plugin', False)
        ]
        return all(checks)
```

    - add constants in `goad/utils.py`
    ```python
    MYPROVIDER = "myprovider"
    ALLOWED_PROVIDERS = [AWS, VIRTUALBOX, AZURE, VMWARE, PROXMOX, LUDUS, MYPROVIDER]
    ```

    - add the check in the command class:
    ```python
    # goad/command/cmd.py
    def check_myprovider(self):
        pass
    ```

    - add the check in the inherited classes : linux.py/ windows.py / wsl.py
    - add the new provider in the provider_factory.py file

- If you use Terraform :
    - create the new provider in `goad/provider/terraform/myprovider.py`
```python
from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *
from goad.log import Log


class MyProviderProvider(TerraformProvider):

    provider_name = MYPROVIDER
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]

    def __init__(self, lab_name):
        super().__init__(lab_name)
        self.resource_group = lab_name
        self.jumpbox_setup_script = 'setup_script.sh'

    def check(self):
        check = super().check()
        myproviders_checks = [
            self.command.mycheck()
        ]
        return check and all(myproviders_checks)

    def start(self):
        # TODO
        pass

    def stop(self):
        # TODO
        pass

    def status(self):
        # TODO
        pass

    def start_vm(self, vm_name):
        # TODO
        pass

    def stop_vm(self, vm_name):
        # TODO
        pass

    def destroy_vm(self, vm_name):
        # TODO
        pass

    def ssh_jumpbox(self):
        # TODO
        pass

    def get_jumpbox_ip(self, ip_range=''):
        # TODO
        pass
```

    - add constants in `goad/utils.py`
    - add the check commands in the cmd.py and the inherited classes : linux.py/ windows.py / wsl.py
    - add the new provider in the provider_factory.py file


- next adapt the menu if needed in menu.py
- add dependencies if needed in the requirements files, in the dependencies.py files and in the config.py files
- add a provider color if you want in instances.py
- define if is_terraform or is_vagrant in instance.py
