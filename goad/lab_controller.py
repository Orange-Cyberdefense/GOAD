import os
from goad.config import Config

from goad.utils import *


class LabController(metaclass=SingletonMeta):

    def __init__(self):
        self.labs = None
        self.current_lab = None
        self.current_provider = None
        self.current_extensions = []
        self.config = None

    def init(self, labs, config):
        self.labs = labs
        self.config = config
        # init lab and provider with config values
        self.set_lab(self.config.get(LAB))
        self.set_provider(self.config.get(PROVIDER))
        return self

    def set_lab(self, lab_name):
        self.current_lab = self.labs.get_lab(lab_name)
        if self.current_lab is not None:
            return self.current_lab
        raise ValueError(f'lab {lab_name} not found')

    def set_provider(self, provider_name):
        if self.current_lab is not None:
            self.current_provider = self.current_lab.get_provider(provider_name)
            if self.current_provider is not None:
                return self.current_provider
            else:
                raise ValueError(f'provider {provider_name} not found')
        else:
            raise ValueError(f'current_lab not set')

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
