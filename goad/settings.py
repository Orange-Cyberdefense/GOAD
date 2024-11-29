from goad.log import Log
from goad.utils import *
from goad.dependencies import Dependencies


class Settings:
    """
    This class keep the current settings
    """

    def __init__(self, lab_manager):
        self.lab_manager = lab_manager
        self.lab_name = None
        self.provider_name = None
        self.provisioner_name = None
        self.extensions_name = []
        self.ip_range = None

    def update(self, instance):
        """
        Update current settings with an instance values
        :param instance: LabInstance object
        """
        self.lab_name = instance.lab_name
        self.provider_name = instance.provider_name
        self.provisioner_name = instance.provisioner_name
        self.ip_range = instance.ip_range
        self.extensions_name = instance.extensions

    def show(self):
        Log.info(f'Current Lab         : {self.lab_name}')
        Log.info(f'Current Provider    : {self.provider_name}')
        Log.info(f'Current Provisioner : {self.provisioner_name}')
        if self.provider_name != LUDUS:
            Log.info(f'Current IP range    : {self.ip_range}.X')
        Log.info(f'Extension(s)        :')
        for extension in self.extensions_name:
            Log.info(f' - {extension}')

    def inline(self):
        if self.provider_name == LUDUS:
            return f'{self.lab_name}/{self.provider_name}/{self.provisioner_name}'
        else:
            return f'{self.lab_name}/{self.provider_name}/{self.provisioner_name}/{self.ip_range}.X'

    def set_lab_name(self, lab_name, refresh=True):
        """
        Set current lab settings if the lab is changed, the provider is changed too
        :param refresh: if setting the lab refresh the provider
        :param lab_name:
        :return: lab_name
        """
        if self.lab_manager.is_lab_exist(lab_name):
            # set lab
            self.lab_name = lab_name
            if refresh:
                self._refresh_provider()
        else:
            Log.error(f'Lab {lab_name} not found')
            Log.info('fallback to GOAD lab')
            self.set_lab_name('GOAD')
        return self.lab_name

    def _refresh_provider(self):
        """
        refresh the provider according to current status
        this function will change the provider with the first found if the selected provider does not exist
        """
        # compare previous provider
        old_provider_name = self.provider_name
        lab = self.lab_manager.get_lab(self.lab_name)
        if lab is not None:
            if lab.get_provider(old_provider_name) is None:
                Log.info(f'Provider {old_provider_name} not found in lab {self.lab_name}')
                new_provider_name = lab.get_first_provider_name()
                Log.info(f'Change provider to {new_provider_name}')
                self.set_provider_name(new_provider_name)

    def set_provider_name(self, provider_name, refresh=True):
        if self.lab_name is not None:
            lab = self.lab_manager.get_lab(self.lab_name)
            provider = lab.get_provider(provider_name)
            if provider is not None:
                self.provider_name = provider.provider_name
                if refresh:
                    self.refresh_provisioner(provider)
            else:
                Log.error(f'provider {provider_name} not found')
                new_provider_name = lab.get_first_provider_name()
                Log.info(f'fallback to first provider found: {new_provider_name}, change it with : "set_provider"')
                self.set_provider_name(new_provider_name)
        else:
            raise ValueError(f"can't set provider because lab_name is not set")
        return self.provider_name

    def refresh_provisioner(self, provider):
        """
        refresh the provisioner according to current status
        this function will change the provisioner if the selected provider does not exist or is not adapted
        """
        if self.provisioner_name is None:
            default_provisioner = provider.default_provisioner
            self.set_provisioner_name(default_provisioner)
        else:
            self.set_provisioner_name(self.provisioner_name)

    def set_provisioner_name(self, provisioner_name):
        if self.lab_name is None:
            raise ValueError(f'current_lab not set')

        if self.provider_name is None:
            raise ValueError(f'current provider is not set')

        lab = self.lab_manager.get_lab(self.lab_name)
        provider = lab.get_provider(self.provider_name)

        if provisioner_name not in provider.allowed_provisioners:
            Log.warning(f'provisioner method {provisioner_name} is not allowed for provider {self.provider_name}')
            Log.info(f'automatic changing provisioner method {provisioner_name} to default for this provider : {provider.default_provisioner}')
            self.provisioner_name = provider.default_provisioner
        else:
            if ((provisioner_name == PROVISIONING_RUNNER and not Dependencies.provisioner_runner_enabled) or
                    (provisioner_name == PROVISIONING_DOCKER and not Dependencies.provisioner_docker_enabled) or (
                    provisioner_name == PROVISIONING_LOCAL and not Dependencies.provisioner_local_enabled) or (
                    provisioner_name == PROVISIONING_REMOTE and not Dependencies.provisioner_remote_enabled)):
                Log.warning(f'provisioner method {provisioner_name} is not enabled')
                Log.info(f'automatic changing provisioner method {provisioner_name} to default for this provider : {provider.default_provisioner}')
                self.provisioner_name = provider.default_provisioner
            else:
                self.provisioner_name = provisioner_name
        return self.provisioner_name

    def set_ip_range(self, ip_range):
        error = False
        try:
            parts = ip_range.split('.')
            if len(parts) >= 3 and all(0 <= int(parts[i]) < 256 for i in range(0, 3)):
                self.ip_range = f'{parts[0]}.{parts[1]}.{parts[2]}'
                return self.ip_range
            else:
                error = True
        except ValueError:
            error = True  # one of the 'parts' not convertible to integer
        except (AttributeError, TypeError):
            error = True  # `ip` isn't even a string
        if error:
            Log.error(f'entered value not valid')
            Log.info(f'fallback to default ip range: 192.168.56.x')
            self.ip_range = '192.168.56'
        return self.ip_range

    def set_extensions(self, extensions_name):
        self.extensions_name = []
        if self.lab_name is not None:
            lab = self.lab_manager.get_lab(self.lab_name)
            for extension_name in extensions_name:
                if lab.get_extension(extension_name) is not None:
                    self.extensions_name.append(extension_name)
                else:
                    Log.error(f'Extension {extension_name} is not available for this lab.')
        else:
            raise ValueError(f"can't set extension because lab_name is not set")
        return self.extensions_name
