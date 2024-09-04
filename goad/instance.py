import json
import shutil
import uuid
from rich.table import Table
from rich import print
from goad.goadpath import *
from goad.log import Log
from goad.exceptions import ProviderPathNotFound
from goad.provisioner.ansible.docker import DockerAnsibleProvisioner
from goad.provisioner.ansible.local import LocalAnsibleProvisionerCmd
from goad.provisioner.ansible.runner import LocalAnsibleProvisionerEmbed
from goad.provisioner.ansible.remote import RemoteAnsibleProvisioner


class LabInstance:

    def __init__(self, instance_id, lab_name, provider_name, provisioner_name, ip_range, extensions=None, status=''):
        if instance_id is None:
            self.instance_id = str(uuid.uuid4())
        else:
            self.instance_id = instance_id
        self.lab_name = lab_name
        self.provider_name = provider_name
        self.provisioner_name = provisioner_name
        self.ip_range = ip_range
        self.status = status
        if extensions is None:
            extensions = []
        self.extensions = extensions

        # prepare model objects
        self.lab = None
        self.provider = None
        self.provisioner = None

    def load(self, labs):
        instance_path = GoadPath.get_instance_path(self.instance_id)
        if not os.path.isdir(instance_path):
            Log.error('instance path not found abort')
            return False

        self.lab = labs.get_lab(self.lab_name)
        if self.lab is None:
            Log.error('lab not found')
            return False

        self.provider = self.lab.get_provider(self.provider_name)
        if self.provider is None:
            Log.error('provider not found')
            return False

        instance_provider_path = GoadPath.get_instance_provider_path(self.instance_id, self.provider_name)

        if not os.path.isdir(instance_provider_path):
            Log.error('instance provider path {instance_provider_path} not found')
            return False

        self.provider.set_instance_path(instance_provider_path)

        if self.provisioner_name == PROVISIONING_DOCKER:
            self.provisioner = DockerAnsibleProvisioner(self.lab_name, self.provider)
        elif self.provisioner_name == PROVISIONING_RUNNER:
            self.provisioner = LocalAnsibleProvisionerEmbed(self.lab_name, self.provider)
        elif self.provisioner_name == PROVISIONING_LOCAL:
            self.provisioner = LocalAnsibleProvisionerCmd(self.lab_name, self.provider)
        elif self.provisioner_name == PROVISIONING_REMOTE:
            self.provisioner = RemoteAnsibleProvisioner(self.lab_name, self.provider)

        if self.provisioner is None:
            Log.error('instance provisioner does not exist')
            return False

        self.provisioner.set_instance_path(instance_path)
        return True

    def show_instance(self):
        table = Table()
        table.add_column('Instance ID')
        table.add_column('Lab')
        table.add_column('Provider')
        table.add_column('IP Range')
        table.add_column('Status')
        table.add_column('Extensions')
        table.add_row(self.instance_id,
                      self.lab_name,
                      self.provider_name,
                      self.ip_range + '.0/24',
                      self.status,
                      ", ".join(self.extensions))
        print(table)

    def is_terraform(self):
        return self.provider_name == AWS or self.provider_name == AZURE or self.provider_name == PROXMOX

    def is_vagrant(self):
        return self.provider_name == VMWARE or self.provider_name == VIRTUALBOX

    def save_json_instance(self):
        instance_info = {
            "id": self.instance_id,
            "lab": self.lab_name,
            "provider": self.provider_name,
            "provisioner": self.provisioner_name,
            "ip_range": self.ip_range,
            "extensions": self.extensions,
            "status": self.status
        }
        json_object = json.dumps(instance_info, indent=4)
        with open(self.instance_path + sep + "instance.json", "w") as outfile:
            outfile.write(json_object)

    def _create_provider_dir(self):
        # create provider dir
        provider_folder = self.instance_path + sep + 'provider'
        os.mkdir(provider_folder, 0o755)

        if self.is_terraform():
            # copy provider recipe
            lab_provider_path = GoadPath.get_lab_provider_path(self.lab_name, self.provider_name) + sep + 'terraform'
            if not os.path.isdir(lab_provider_path):
                Log.error(f'Lab Provider path {lab_provider_path} not found')
                raise ProviderPathNotFound('path not found')
            shutil.copytree(lab_provider_path, self.instance_provider_path, dirs_exist_ok=True)
            for tf_file in Utils.list_folders(self.instance_provider_path):
                if tf_file.endswith('tf'):
                    Utils.replace_in_file(self.instance_provider_path + sep + tf_file, '192.168.56', self.ip_range)
            return True

        if self.is_vagrant():
            lab_provider_path = GoadPath.get_lab_provider_path(self.lab_name, self.provider_name) + sep + 'Vagrantfile'
            if not os.path.isfile(lab_provider_path):
                Log.error(f'Lab Provider path {lab_provider_path} not found')
                raise ProviderPathNotFound('path not found')
            os.mkdir(self.instance_provider_path, 0o755)
            instance_vagrant_file = self.instance_provider_path + sep + 'Vagrantfile'
            shutil.copy(lab_provider_path, instance_vagrant_file)
            Utils.replace_in_file(instance_vagrant_file, '192.168.56', self.ip_range)
            return True

        return False

    def _create_provisioning_inventory(self):
        # create provisioning inventory
        lab_provider_inventory = GoadPath.get_provider_inventory_file(self.lab_name, self.provider_name)
        instance_provider_inventory = self.instance_path + sep + 'inventory'
        if os.path.isfile(lab_provider_inventory):
            # copy provider inventory
            shutil.copy(lab_provider_inventory, instance_provider_inventory)
            # change IP in inventory
            Utils.replace_in_file(instance_provider_inventory, '192.168.56', self.ip_range)

    def create_instance_folder(self, force=False):
        instance_exist = False
        if os.path.isdir(self.instance_path):
            instance_exist = True
            if force:
                Log.info(f'Instance {self.instance_id} already exist override')
            else:
                Log.error(f'Instance {self.instance_id} already exist abort')
                return False

        # create instance dir
        if not instance_exist:
            try:
                os.mkdir(self.instance_path, 0o755)
            except Exception as e:
                Log.error('Instance dir creation error')
                return False

        try:
            self._create_provider_dir()
        except ProviderPathNotFound as e:
            # delete instance
            self.delete_instance()
            Log.info('instance deleted')
            return False

        self._create_provisioning_inventory()
        self.status = TO_PROVIDE
        self.save_json_instance()
        Log.success(f'Instance [yellow]{self.instance_id}[/yellow] created')
        return True

    def set_status(self, status):
        self.status = status
        self.save_json_instance()

    def delete_instance(self):
        pass
