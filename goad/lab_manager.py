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

    def init(self, config):
        # Prepare all labs objects
        self.labs = Labs()
        # Prepare all instance objects
        self.lab_instances = LabInstances()
        # create current settings object
        self.current_settings = Settings(self)

        # init lab current config values
        self.config = config
        self.current_settings.set_lab_name(self.config.get(LAB), False)
        self.current_settings.set_provider_name(self.config.get(PROVIDER), False)
        self.current_settings.set_provisioner_name(self.config.get(PROVISIONER))
        self.current_settings.set_ip_range(self.config.get(IP_RANGE))
        return self

    def show_settings(self):
        self.current_settings.show()

    def inline_settings(self):
        return self.current_settings.inline()

    def create_instance(self):
        instance = LabInstance(None, self.current_settings.lab_name, self.current_settings.provider_name, self.current_settings.provisioner_name,
                               self.current_settings.ip_range)
        result = instance.create_instance_folder()
        if result:
            self.lab_instances.add_instance(instance)
            self.load_instance(instance.instance_id)
        else:
            Log.error('Error during creating instance folder')

    def load_instance(self, instance_id):
        instance = self.lab_instances.get_instance(instance_id)
        if instance is not None:
            loading_result = instance.load(self.labs)
            if loading_result:
                # unload previous instance if exist
                self.current_instance = None
                # load lab instance change current context
                self.current_settings.update(instance)
                # load instance
                self.current_instance = instance
                Log.success(f'Instance {instance_id} loaded')
                self.current_instance.show_instance()
        else:
            Log.error('Instance not found in workspace')

    def unload_instance(self):
        self.current_instance = None

    def set_lab(self, lab_name):
        if self.current_instance is None:
            self.current_settings.set_lab_name(lab_name)
        else:
            Log.error("Can't change lab if instance is selected")
            Log.info('use unload_instance to quit the current instance')

    def set_provider(self, provider_name):
        if self.current_instance is None:
            self.current_settings.set_provider_name(provider_name)
        else:
            Log.error("Can't change provider if instance is selected")
            Log.info('use unload_instance to quit the current instance')

    def set_provisioner(self, provisioner_name):
        self.current_settings.set_provisioner_name(provisioner_name)

    def set_ip_range(self, ip_range):
        self.current_settings.set_ip_range(ip_range)

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

    def get_labs(self):
        return self.labs

    # instance function
    def get_current_instance_id(self):
        if self.current_instance is not None:
            return self.current_instance.instance_id
        return ''

    def get_current_instance(self):
        return self.current_instance

    def get_current_instance_lab(self):
        return self.current_instance.lab

    def get_current_instance_provider(self):
        return self.current_instance.provider

    def get_current_instance_provisioner(self):
        return self.current_instance.provisioner

