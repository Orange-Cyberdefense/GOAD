from goad.utils import *

sep = os.path.sep
project_path = os.path.normpath(os.path.dirname(os.path.abspath(__file__)) + sep + '..')


class GoadPath:

    @staticmethod
    def get_config_path():
        home = str(Path.home())
        return home + sep + '.goad'

    @staticmethod
    def get_config_file():
        return GoadPath.get_config_path() + sep + 'goad.ini'

    @staticmethod
    def get_global_inventory_path():
        return project_path + os.path.sep + 'globalsettings.ini'

    @staticmethod
    def get_workspace_path():
        return project_path + sep + 'workspace'

    @staticmethod
    def get_project_path():
        return project_path + sep

    @staticmethod
    def get_template_path(provider):
        """
        :return:  <project>/template/provider/<provider>/
        """
        return project_path + sep + 'template' + sep + 'provider' + sep + provider + sep

    # config
    @staticmethod
    def get_playbooks_lab_config():
        """
        :return:  <project>/playbooks.yml
        """
        return project_path + os.path.sep + 'playbooks.yml'

    # LAB recipe
    @staticmethod
    def get_labs_path():
        """
        :return: <project>/ad
        """
        return project_path + sep + 'ad'

    @staticmethod
    def get_lab_path(lab_name):
        """
        :return: <project>/ad/<lab_name>
        """
        return GoadPath.get_labs_path() + sep + lab_name

    @staticmethod
    def get_lab_data_path(lab_name):
        """
        :return: <project>/ad/<lab_name>/data
        """
        return GoadPath.get_lab_path(lab_name) + sep + 'data'

    @staticmethod
    def get_lab_providers_path(lab_name):
        """
        :return: <project>/ad/<lab_name>/providers
        """
        return project_path + os.path.sep + 'ad' + os.path.sep + lab_name + os.path.sep + 'providers'

    @staticmethod
    def get_lab_provider_path(lab_name, provider_name):
        """
        :return:  <project>/ad/<lab_name>/providers/<provider>
        """
        return GoadPath.get_lab_providers_path(lab_name) + sep + provider_name

    @staticmethod
    def get_provider_inventory_file(lab_name, provider_name):
        """
        :return: <project>/ad/<lab_name>/providers/<provider>/inventory
        """
        return GoadPath.get_lab_provider_path(lab_name, provider_name) + sep + 'inventory'

    @staticmethod
    def get_lab_inventory_file(lab_name):
        """
        :return: <project>/ad/<lab_name>/data/inventory
        """
        return GoadPath.get_lab_path(lab_name) + os.path.sep + 'data' + os.path.sep + 'inventory'

    # script
    @staticmethod
    def get_script_path():
        """
        :return: <project>/scripts
        """
        return project_path + os.path.sep + 'scripts'

    @staticmethod
    def get_script_file(script):
        """
        :return: <project>/scripts/<script>
        """
        return project_path + os.path.sep + 'scripts' + os.path.sep + script

    # ANSIBLE
    @staticmethod
    def get_provisioner_path():
        """
        :return: <project>/ansible/
        """
        return project_path + os.path.sep + 'ansible' + sep

    # Instances
    @staticmethod
    def get_instance_path(instance_id):
        """
        :return: <project>/workspace/<instance_id>
        """
        return GoadPath.get_workspace_path() + sep + instance_id

    @staticmethod
    def get_instance_provider_path(instance_id):
        return GoadPath.get_instance_path(instance_id) + sep + 'provider'

    # EXTENSIONS
    @staticmethod
    def get_extensions_path():
        return project_path + os.path.sep + 'extensions'

    @staticmethod
    def get_extension_path(extension_name):
        """
        :return: <project>/extensions/<extension_name>/
        """
        return GoadPath.get_extensions_path() + os.path.sep + extension_name + os.path.sep

    @staticmethod
    def get_extension_config_file(extension_name):
        """
        :return: <project>/extensions/<extension_name>/
        """
        return GoadPath.get_extensions_path() + os.path.sep + extension_name + os.path.sep + 'extension.json'

    @staticmethod
    def get_extension_providers_path(extension_name):
        """
        :return: <project>/extensions/<extension_name>/provider
        """
        return GoadPath.get_extension_path(extension_name) + 'providers'

    @staticmethod
    def get_extension_providers_provider_path(extension_name, provider_name):
        """
        :return:  <project>/extensions/<extension_name>/providers/<provider>/
        """
        return GoadPath.get_extension_providers_path(extension_name) + os.path.sep + provider_name + os.path.sep

    @staticmethod
    def get_extension_ansible_path(extension_name):
        """
        :return <project>/extensions/<extension_name>/ansible
        """
        return GoadPath.get_extension_path(extension_name) + 'ansible'
