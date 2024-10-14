from goad.instances import LabInstances
from goad.instance import LabInstance
from goad.labs import Labs
from goad.provisioner.ansible.ansible import *
from goad.settings import Settings


class LabManager(metaclass=SingletonMeta):

    def __init__(self):
        self.labs = None
        self.current_lab = None
        self.current_provider = None
        self.current_provisioner = None
        self.current_extensions = []
        self.current_ip_range = None

        self.config = None
        self.lab_instances = None
        self.current_instance = None
        self.current_settings = None

    def init(self, config, args):
        # Prepare all labs objects
        self.labs = Labs(config)
        # Prepare all instance objects
        self.lab_instances = LabInstances(config)
        # create current settings object
        self.current_settings = Settings(self)
        # init lab current config values
        self.config = config
        self.current_settings.set_lab_name(self.config.get_value('default', LAB), False)
        self.current_settings.set_provider_name(self.config.get_value('default', PROVIDER), False)
        self.current_settings.set_provisioner_name(self.config.get_value('default', PROVISIONER))
        self.current_settings.set_ip_range(self.config.get_value('default', IP_RANGE))
        if args.extensions:
            self.current_settings.set_extensions(args.extensions)
        return self

    def load_default_instance(self):
        # load default instance
        for instance_id, instance in self.lab_instances.instances.items():
            if instance.is_default:
                self.load_instance(instance_id)
                break

    def show_settings(self):
        Log.success('Current Settings : ')
        self.current_settings.show()
        print()
        Log.success(f'Configuration File content : {GoadPath.get_config_file()} (merged with args for the default section)')
        self.config.show()

    def inline_settings(self):
        return self.current_settings.inline()

    def update_instance_files(self, arg=''):
        if self.current_instance is not None:
            self.current_instance.update_instance_folder()

    def create_instance(self):
        instance = LabInstance(None, self.current_settings.lab_name, self.config, self.current_settings.provider_name, self.current_settings.provisioner_name,
                               self.current_settings.ip_range, extensions=self.current_settings.extensions_name)
        result = instance.create_instance_folder()
        if result:
            self.lab_instances.add_instance(instance)
            self.load_instance(instance.instance_id, creation=True)
            self.lab_instances.show_instances(current_instance_id=instance.instance_id, filter_instance_id=instance.instance_id)

            if self.lab_instances.nb_instances() == 1:
                # only instance, set as default
                self.set_as_default_instance()
            return True
        else:
            Log.error('Error during creating instance folder')
            return False

    def load_instance(self, instance_id, creation=False):
        instance = self.lab_instances.get_instance(instance_id)
        if instance is not None:
            loading_result = instance.load(self.labs, creation)
            if loading_result:
                # unload previous instance if exist
                self.current_instance = None
                # load lab instance change current context
                self.current_settings.update(instance)
                # load instance
                self.current_instance = instance
                Log.success(f'Instance {instance_id} loaded')
        else:
            Log.error('Instance not found in workspace')

    def set_as_default_instance(self):
        if self.current_instance is not None:
            for instance_id, instance in self.lab_instances.instances.items():
                if instance_id == self.current_instance.instance_id:
                    instance.is_default = True
                else:
                    instance.is_default = False
                instance.save_json_instance()
        else:
            Log.error('No instance selected')

    def unload_instance(self):
        self.current_instance = None
        self.current_settings.set_extensions([])

    def delete_instance(self):
        deleted = False
        if self.current_instance is not None:
            deleted = self.current_instance.delete_instance()
            if deleted:
                self.lab_instances.del_instance(self.current_instance.instance_id)
                self.unload_instance()
        return deleted

    def set_lab(self, lab_name):
        if self.current_instance is None:
            self.current_settings.set_lab_name(lab_name)
        else:
            Log.error("Can't change lab if instance is selected")
            Log.info('use unload to quit the current instance')

    def set_provider(self, provider_name):
        if self.current_instance is None:
            self.current_settings.set_provider_name(provider_name)
        else:
            Log.error("Can't change provider if instance is selected")
            Log.info('use unload to quit the current instance')

    def set_provisioner(self, provisioner_name):
        self.current_settings.set_provisioner_name(provisioner_name)

    def set_ip_range(self, ip_range):
        self.current_settings.set_ip_range(ip_range)

    def get_ip_range(self):
        return self.current_settings.ip_range

    def set_extensions(self, extensions_name):
        self.current_settings.set_extensions(extensions_name)

    def get_labs(self):
        return self.labs.get_labs_list()

    def get_lab(self, lab_name):
        return self.labs.get_lab(lab_name)

    def is_lab_exist(self, lab_name):
        return self.labs.is_exist(lab_name)

    def get_current_lab_name(self):
        return self.current_settings.lab_name

    def get_current_provider_name(self):
        return self.current_settings.provider_name

    def check(self):
        lab = self.get_lab(self.get_current_lab_name())
        provider = lab.get_provider(self.get_current_provider_name())
        if provider is not None:
            return provider.check()
        else:
            Log.error('error provider not found')
            return False

    # instance function
    def get_current_instance_id(self):
        if self.current_instance is not None:
            return self.current_instance.instance_id
        return ''

    def get_current_instance(self):
        return self.current_instance

    def get_current_instance_lab(self):
        if self.current_instance is None:
            return None
        return self.current_instance.lab

    def get_current_instance_provider(self):
        if self.current_instance:
            return self.current_instance.provider
        else:
            return None

    def get_instance_options(self):
        return list(self.lab_instances.instances.keys())

    def get_current_instance_provisioner(self):
        return self.current_instance.provisioner

    def get_labs_options(self):
        return list(self.labs.labs.keys())

    def get_provider_options(self):
        lab_name = self.current_settings.lab_name
        options = []
        for lab in self.labs.get_labs_list():
            if lab.lab_name == lab_name:
                options = list(lab.providers.keys())
                break
        return options

    def provisioning_method_options(self):
        lab_name = self.current_settings.lab_name
        lab = self.get_lab(lab_name)
        provider = lab.get_provider(self.current_settings.provider_name)
        return provider.allowed_provisioners
