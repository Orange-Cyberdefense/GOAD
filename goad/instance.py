import json
import shutil
from jinja2 import Template, Environment, FileSystemLoader
from goad.goadpath import *
from goad.log import Log
from goad.exceptions import ProviderPathNotFound, JumpBoxInitFailed
from goad.provisioner.provisioner_factory import ProvisionerFactory
from goad.utils import *


class LabInstance:

    def __init__(self, instance_id, lab_name, config, provider_name, provisioner_name, ip_range, extensions=None, status='', default=False):
        if instance_id is None:
            random_id = ''.join(random.choices(string.hexdigits, k=6))
            self.instance_id = f'{random_id}-{lab_name}-{provider_name}'.lower()
        else:
            self.instance_id = instance_id
        self.lab_name = lab_name
        self.config = config
        self.provider_name = provider_name
        self.provisioner_name = provisioner_name
        self.ip_range = ip_range
        self.status = status
        if extensions is None:
            extensions = []
        self.extensions = extensions
        self.is_default = default

        # paths
        self.instance_path = GoadPath.get_instance_path(self.instance_id)
        self.instance_provider_path = GoadPath.get_instance_provider_path(self.instance_id)

        # prepare model objects
        self.lab = None
        self.provider = None
        self.provisioner = None

    def load(self, labs, creation=False):
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

        if self.provider_name == AZURE:
            self.provider.set_resource_group(self.lab_name + '-' + self.instance_id)
        if self.provider_name == AWS:
            self.provider.set_tag(self.lab_name + '-' + self.instance_id)
        if self.provider_name == LUDUS:
            user_id = self.lab_name + self.instance_id.split('-')[0]
            user_id = user_id.replace('-', '').replace('_', '')
            self.provider.set_lab_user(user_id[:19])

        if not os.path.isdir(self.instance_provider_path):
            Log.error('instance provider path {instance_provider_path} not found')
            return False

        self.provider.set_instance_path(self.instance_provider_path)

        self.provisioner = ProvisionerFactory.get_provisioner(self.provisioner_name, self, creation)

        if self.provisioner is None:
            Log.error('instance provisioner does not exist')
            return False

        self.provisioner.set_instance_path(instance_path)
        return True

    def is_terraform(self):
        return self.provider_name == AWS or self.provider_name == AZURE or self.provider_name == PROXMOX

    def is_vagrant(self):
        return self.provider_name == VMWARE or self.provider_name == VMWARE_ESXI or self.provider_name == VIRTUALBOX

    def is_ludus(self):
        return self.provider_name == LUDUS

    def enable_extension(self, extension_name):
        if extension_name not in self.extensions:
            self.extensions.append(extension_name)
            self.save_json_instance()
        Log.info('Extension enabled update folders')
        self.update_instance_folder()

    def disable_extension(self, extension_name):
        if extension_name in self.extensions:
            self.extensions.remove(extension_name)
            self.save_json_instance()
            self.update_instance_folder()

    def save_json_instance(self):
        instance_info = {
            "id": self.instance_id,
            "lab": self.lab_name,
            "provider": self.provider_name,
            "provisioner": self.provisioner_name,
            "ip_range": self.ip_range,
            "extensions": self.extensions,
            "status": self.status,
            "is_default": self.is_default
        }
        json_object = json.dumps(instance_info, indent=4)
        with open(self.instance_path + sep + "instance.json", "w") as outfile:
            outfile.write(json_object)

    def _create_vagrantfile(self):
        # load lab vagrantfile
        lab_environment = Environment(loader=FileSystemLoader(GoadPath.get_lab_provider_path(self.lab_name, self.provider_name)))
        lab_vagrantfile_template = lab_environment.get_template("Vagrantfile")
        lab_vagrantfile_content = lab_vagrantfile_template.render(
            lab_name=self.lab_name,
            ip_range=self.ip_range
        )

        # load lab extensions
        lab_extensions_content = ''
        for extension in self.extensions:
            extension_provider_folder = GoadPath.get_extension_providers_provider_path(extension, self.provider_name)
            extension_environment = Environment(loader=FileSystemLoader(extension_provider_folder))
            lab_extension_vagrantfile_template = extension_environment.get_template("Vagrantfile")
            lab_extensions_content += lab_extension_vagrantfile_template.render(
                lab_name=self.lab_name,
                ip_range=self.ip_range
            ) + "\n"

        # load extensions Vagrantfile into instance
        use_provisioning_vm = True if self.provisioner_name == PROVISIONING_VM else False
        environment = Environment(loader=FileSystemLoader(GoadPath.get_template_path(self.provider_name)))
        vagrantfile_template = environment.get_template("Vagrantfile")
        vagrantfile_content = vagrantfile_template.render(
            lab_name=self.lab_name,
            lab=lab_vagrantfile_content,
            extensions=lab_extensions_content,
            provider_name=self.provider_name,
            ip_range=self.ip_range,
            use_provisioning_vm=use_provisioning_vm
        )

        # create vagrantfile
        instance_vagrant_file = self.instance_provider_path + sep + 'Vagrantfile'
        with open(instance_vagrant_file, mode="w", encoding="utf-8") as vagrantfile:
            vagrantfile.write(vagrantfile_content)
            Log.info(f'Instance vagrantfile created : {Utils.get_relative_path(instance_vagrant_file)}')

    def _create_esxi_env(self):
        # get esxi config
        config = self.config
        esxi_hostname = config.get_value('vmware_esxi', 'esxi_hostname')
        esxi_username = config.get_value('vmware_esxi', 'esxi_username')
        esxi_password = config.get_value('vmware_esxi', 'esxi_password')
        esxi_net_nat = config.get_value('vmware_esxi', 'esxi_net_nat')
        esxi_net_domain = config.get_value('vmware_esxi', 'esxi_net_domain')
        esxi_datastore = config.get_value('vmware_esxi', 'esxi_datastore')
        
        # load .env template
        environment = Environment(loader=FileSystemLoader(GoadPath.get_template_path(self.provider_name)))
        envfile_template = environment.get_template(".env")
        envfile_content = envfile_template.render(
            esxi_hostname = esxi_hostname,
            esxi_username = esxi_username,
            esxi_password = esxi_password,
            esxi_net_nat = esxi_net_nat,
            esxi_net_domain = esxi_net_domain,
            esxi_datastore = esxi_datastore
        )

        # create .env file
        instance_env_file = self.instance_provider_path + sep + '.env'
        with open(instance_env_file, mode="w", encoding="utf-8") as vagrantfile:
            vagrantfile.write(envfile_content)
            Log.info(f'Instance .env created : {Utils.get_relative_path(instance_env_file)}')

    def _create_ludus_config_file(self):
        # load lab vagrantfile
        lab_environment = Environment(loader=FileSystemLoader(GoadPath.get_lab_provider_path(self.lab_name, self.provider_name)))
        lab_ludus_config_file_template = lab_environment.get_template("config.yml")
        lab_ludus_config_file_content = lab_ludus_config_file_template.render(
            lab_name=self.lab_name,
            range_id="{{ range_id }}",
            ip_range=self.ip_range
        )

        # load lab extensions
        lab_extensions_ludus_config_file_content = ''
        for extension in self.extensions:
            extension_provider_folder = GoadPath.get_extension_providers_provider_path(extension, self.provider_name)
            extension_environment = Environment(loader=FileSystemLoader(extension_provider_folder))
            lab_extension_ludus_config_file_template = extension_environment.get_template("config.yml")
            lab_extensions_ludus_config_file_content += lab_extension_ludus_config_file_template.render(
                lab_name=self.lab_name,
                range_id="{{ range_id }}",
                ip_range=self.ip_range
            ) + "\n"

        # load lab + extension into instance config
        environment = Environment(loader=FileSystemLoader(GoadPath.get_template_path(self.provider_name)))
        ludus_config_file_template = environment.get_template("config.yml")
        ludus_config_file_template_content = ludus_config_file_template.render(
            lab_name=self.lab_name,
            lab=lab_ludus_config_file_content,
            extensions=lab_extensions_ludus_config_file_content,
            provider_name=self.provider_name
        )

        # create vagrantfile
        instance_ludus_file = self.instance_provider_path + sep + 'config.yml'
        with open(instance_ludus_file, mode="w", encoding="utf-8") as ludusfile:
            ludusfile.write(ludus_config_file_template_content)
            Log.info(f'Instance vagrantfile created : {Utils.get_relative_path(instance_ludus_file)}')

    def _create_terraform_folder(self):
        # load lab files
        lab_environment = Environment(loader=FileSystemLoader(GoadPath.get_lab_provider_path(self.lab_name, self.provider_name)))
        lab_windows_template = lab_environment.get_template("windows.tf")
        windows_vm = lab_windows_template.render(
            ip_range=self.ip_range
        )

        linux_vm = ''
        if os.path.isfile(GoadPath.get_lab_provider_path(self.lab_name, self.provider_name) + sep + 'linux.tf'):
            lab_environment = Environment(loader=FileSystemLoader(GoadPath.get_lab_provider_path(self.lab_name, self.provider_name)))
            lab_windows_template = lab_environment.get_template("linux.tf")
            linux_vm = lab_windows_template.render(
                ip_range=self.ip_range
            )

        # load lab extensions content
        for extension in self.extensions:
            extension_provider_folder = GoadPath.get_extension_providers_provider_path(extension, self.provider_name)
            extension_environment = Environment(loader=FileSystemLoader(extension_provider_folder))
            if os.path.isfile(extension_provider_folder + sep + 'linux.tf'):
                lab_extension_linux_template = extension_environment.get_template("linux.tf")
                linux_vm += "\n" + lab_extension_linux_template.render(
                    lab_name=self.lab_name,
                    ip_range=self.ip_range
                ) + "\n"
            if os.path.isfile(extension_provider_folder + sep + 'windows.tf'):
                lab_extension_windows_template = extension_environment.get_template("windows.tf")
                windows_vm += "\n" + lab_extension_windows_template.render(
                    lab_name=self.lab_name,
                    ip_range=self.ip_range
                ) + "\n"

        # load template folder
        environment = Environment(loader=FileSystemLoader(GoadPath.get_template_path(self.provider_name)))

        for template in Utils.list_files(GoadPath.get_template_path(self.provider_name)):
            tf_template = environment.get_template(template)
            tf_content = tf_template.render(
                windows_vms=windows_vm,
                linux_vms=linux_vm,
                lab_identifier=self.lab_name + '-' + self.instance_id,
                lab_name=self.lab_name,
                ip_range=self.ip_range,
                provider_name=self.provider_name,
                config=self.config
            )
            # create terraform files
            instance_tf_file = self.instance_provider_path + sep + template
            with open(instance_tf_file, mode="w", encoding="utf-8") as tf_file:
                tf_file.write(tf_content)
                Log.success(f'Instance terraform file created : {Utils.get_relative_path(instance_tf_file)}')

    def _create_provider_dir(self):
        # create provider dir
        # workspace/provider
        if not os.path.isdir(self.instance_provider_path):
            os.mkdir(self.instance_provider_path, 0o755)
        # workspace/ssh_keys
        ssh_folder = self.instance_path + sep + 'ssh_keys'
        if not os.path.isdir(ssh_folder):
            os.mkdir(ssh_folder, 0o750)
        Log.info('Create instance providing files')
        if self.is_vagrant():
            self._create_vagrantfile()
        if self.provider_name == VMWARE_ESXI:
            self._create_esxi_env()
        if self.is_ludus():
            self._create_ludus_config_file()
        if self.is_terraform():
            self._create_terraform_folder()

    def _create_provisioning_lab_inventory(self, inventory_file):
        Log.info(f'Create lab provisioning file {inventory_file}')
        # create lab inventory
        lab_provider_path = GoadPath.get_lab_data_path(self.lab_name)
        environment = Environment(loader=FileSystemLoader(lab_provider_path))
        # create inventory template
        inventory_template = environment.get_template(inventory_file)
        instance_inventory_content = inventory_template.render(
            lab_name=self.lab_name,
            ip_range=self.ip_range,
            provider_name=self.provider_name
        )
        # create instance inventory file
        instance_inventory_file = self.instance_path + sep + inventory_file
        with open(instance_inventory_file, mode="w", encoding="utf-8") as instance_inventory_file_open:
            instance_inventory_file_open.write(instance_inventory_content)
            Log.success(f'Lab inventory file created : {Utils.get_relative_path(instance_inventory_file)}')

    def _create_provisioning_provider_inventory(self):
        Log.info('Create instance provisioning files')
        # create provisioning inventory
        lab_provider_path = GoadPath.get_lab_provider_path(self.lab_name, self.provider_name)
        environment = Environment(loader=FileSystemLoader(lab_provider_path))
        # create inventory template
        inventory_template = environment.get_template("inventory")
        instance_inventory_content = inventory_template.render(
            lab_name=self.lab_name,
            ip_range=self.ip_range,
            provider_name=self.provider_name
        )
        # create instance inventory file
        instance_inventory_file = self.instance_path + sep + 'inventory'
        with open(instance_inventory_file, mode="w", encoding="utf-8") as inventory_file:
            inventory_file.write(instance_inventory_content)
            Log.success(f'Instance inventory file created : {Utils.get_relative_path(instance_inventory_file)}')

    def _create_extensions_inventory(self):
        Log.info('Create instance extensions inventory files')

        for extension in self.extensions:
            extension_folder = GoadPath.get_extension_path(extension)
            extension_environment = Environment(loader=FileSystemLoader(extension_folder))
            instance_extension_inventory_template = extension_environment.get_template("inventory")
            instance_extension_inventory_content = instance_extension_inventory_template.render(
                lab_name=self.lab_name,
                ip_range=self.ip_range,
                provider_name=self.provider_name
            )

            # create instance extension inventory file
            instance_extension_inventory_file = self.instance_path + sep + extension + '_inventory'
            with open(instance_extension_inventory_file, mode="w", encoding="utf-8") as inventory_file:
                inventory_file.write(instance_extension_inventory_content)
                Log.success(f'Instance inventory file created : {Utils.get_relative_path(instance_extension_inventory_file)}')

    def update_instance_folder(self):
        self.create_instance_folder(True)

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
            return False

        self._create_provisioning_lab_inventory('inventory_disable_vagrant')
        self._create_provisioning_provider_inventory()
        self._create_extensions_inventory()
        if self.status is not None and not force:
            self.status = CREATED
        self.save_json_instance()
        Log.info(f'Instance {self.instance_id} created')
        return True

    def set_status(self, status):
        self.status = status
        self.save_json_instance()

    def get_status(self):
        return self.status

    def delete_instance(self):
        if not os.path.isdir(self.instance_path):
            Log.error('Instance does not exist abort')
            return False
        Log.info(f'Instance id {self.instance_id} will be deleted.')
        Log.info(f'Instance folder {self.instance_path} will be deleted.')
        Log.warning(f'Are you sure ?')
        if Utils.confirm('(y/N)'):
            lab_destroyed = self.provider.destroy()
            if lab_destroyed:
                shutil.rmtree(self.instance_path, ignore_errors=False, onerror=None)
                Log.success('instance deleted')
                return True
            else:
                Log.error('Error during lab destruction')
        return False

    def update_ip_range(self, ip_range):
        self.ip_range = ip_range
        self.update_instance_folder()
