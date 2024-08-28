import os
from goad.config import Config
from goad.provisioner.ansible.docker import DockerAnsibleProvisioner
from goad.provisioner.ansible.local import LocalAnsibleProvisionerCmd
from goad.provisioner.ansible.runner import LocalAnsibleProvisionerEmbed
from goad.provisioner.ansible.remote import RemoteAnsibleProvisioner

from goad.utils import *
from goad.provisioner.provisioner import *
from goad.provisioner.ansible.ansible import *


class LabManager(metaclass=SingletonMeta):

    def __init__(self):
        self.labs = None
        self.current_lab = None
        self.current_provider = None
        self.current_provisioner = None
        self.current_extensions = []
        self.config = None

    def init(self, labs, config):
        self.labs = labs
        self.config = config
        # init lab and provider with config values
        self.set_lab(self.config.get(LAB))
        self.set_provider(self.config.get(PROVIDER))
        self.set_provisioner(self.config.get(PROVISIONER))
        return self

    def set_lab(self, lab_name):
        self.current_lab = self.labs.get_lab(lab_name)
        if self.current_lab is not None:
            if self.current_provider is not None:
                # lab changed, change provider if needed
                old_provider_name = self.current_provider.provider_name
                # check if previous provider is present in the lab
                if self.current_lab.get_provider(old_provider_name) is None:
                    Log.info(f'Provider {old_provider_name} not found in lab {lab_name}')
                    new_provider_name = self.current_lab.get_first_provider_name()
                    Log.info(f'Change provider to {new_provider_name}')
                    self.set_provider(new_provider_name)
            return self.current_lab
        else:
            Log.error(f'lab {lab_name} not found')
            Log.info('fallback to GOAD lab')
            self.set_lab('GOAD')

    def set_provider(self, provider_name):
        if self.current_lab is not None:
            self.current_provider = self.current_lab.get_provider(provider_name)
            if self.current_provider is not None:
                if self.current_provisioner is None:
                    default_provisioner = self.current_provider.default_provisioner
                    self.set_provisioner(default_provisioner)
                else:
                    self.set_provisioner(self.current_provisioner.provisioner_name)
                return self.current_provider
            else:
                Log.error(f'provider {provider_name} not found')
                new_provider_name = self.current_lab.get_first_provider_name()
                Log.info(f'fallback to first provider found: {new_provider_name}, change it with : "set_provider"')
                self.set_provider(new_provider_name)
        else:
            raise ValueError(f'current_lab not set')

    def set_provisioner(self, provisioner_name):
        if self.current_lab is None:
            raise ValueError(f'current_lab not set')

        if self.current_provider is None:
            raise ValueError(f'current provider is not set')

        if provisioner_name not in self.current_provider.allowed_provisioners:
            Log.info(f'provisioner method {provisioner_name} is not allowed for provider {self.current_provider.provider_name}')
            Log.info(f'automatic changing provisioner method {provisioner_name} to default for this provider : {self.current_provider.default_provisioner}')
            provisioner_name = self.current_provider.default_provisioner

        if provisioner_name == PROVISIONING_DOCKER:
            self.current_provisioner = DockerAnsibleProvisioner(self.current_lab.lab_name, self.current_provider)
        elif provisioner_name == PROVISIONING_RUNNER:
            self.current_provisioner = LocalAnsibleProvisionerEmbed(self.current_lab.lab_name, self.current_provider)
        elif provisioner_name == PROVISIONING_LOCAL:
            self.current_provisioner = LocalAnsibleProvisionerCmd(self.current_lab.lab_name, self.current_provider)
        elif provisioner_name == PROVISIONING_REMOTE:
            self.current_provisioner = RemoteAnsibleProvisioner(self.current_lab.lab_name, self.current_provider)

        if self.current_provisioner is None:
            raise ValueError(f'error during provisioner set {provisioner_name} not found')

        return self.current_provisioner

    def get_labs(self):
        return self.labs.get_labs_list()

    def get_current_lab(self):
        return self.current_lab

    def get_current_lab_name(self):
        return self.current_lab.lab_name

    def get_current_provider(self):
        return self.current_provider

    def get_current_provider_name(self):
        return self.current_provider.provider_name

    def get_lab_providers(self, lab):
        return self.labs.get_current_lab(lab).providers.keys()

    def get_current_provisioner(self):
        return self.current_provisioner

    def get_current_provisioner_name(self):
        return self.current_provisioner.provisioner_name
