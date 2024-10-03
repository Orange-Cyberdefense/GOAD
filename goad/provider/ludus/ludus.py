from goad.provider.provider import Provider
from goad.utils import *
from goad.log import Log
import json
import time


class LudusProvider(Provider):
    provider_name = LUDUS
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER]
    update_ip_range = True

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        self.api_key = config.get_value('ludus', 'ludus_api_key')

    def check(self):
        check_ludus = self.command.check_ludus()

        if check_ludus:
            ludus_version = self.command.get_ludus_version_output(self.api_key)
            if 'No API key loaded' in ludus_version:
                Log.error('Please add the ludus api key to HOME/.goad/goad.ini file')
                check_ludus = False

        check_disk = self.command.check_disk()
        check_ram = self.command.check_ram()
        check_ansible = self.command.check_ansible()
        check_gem_winrm = self.command.check_gem('winrm')
        check_gem_winrmfs = self.command.check_gem('winrm-fs')
        check_gem_winrme = self.command.check_gem('winrm-elevated')
        return check_ludus and check_disk and check_ram and check_ansible and check_gem_winrm and check_gem_winrmfs and check_gem_winrme

    def install(self):
        set_config_result = self.command.run_ludus('range config set -f config.yml', self.path, self.api_key)
        if not set_config_result:
            return False

        deploy_result = self.command.run_ludus('range deploy', self.path, self.api_key)
        if not deploy_result:
            return False

        while True:
            ludus_status = self.command.run_ludus_status(self.path, self.api_key, do_log=False)
            if ludus_status is None:
                return False
            try:
                range_status = json.loads(ludus_status)
                range_state = range_status['rangeState']
                if range_state == 'ERROR':
                    Log.error('Error during deployment')
                    self.command.run_ludus('range errors', self.path, self.api_key)
                    return False
                elif range_state == 'DEPLOYING':
                    Log.info('deploying...be patient')
                elif range_state == 'SUCCESS':
                    range_number = range_status['rangeNumber']
                    Log.info(f'deployment finished, range number : {range_number}')
                    break
                else:
                    Log.warning(f'Unknow status : {range_state}')
            except Exception as e:
                Log.error('')
                return False
            time.sleep(30)
        return True

    def get_ip_range(self):
        try:
            ludus_status = self.command.run_ludus_status(self.path, self.api_key)
            range_status = json.loads(ludus_status)
            range_number = range_status['rangeNumber']
            Log.info(f'Ludus ip range : {range_number}')
            return f'10.{range_number}.10'
        except Exception as e:
            Log.error('Error during ludus status')
            return None


    def destroy(self):
        return self.command.run_ludus('range rm', self.path, self.api_key)

    def start(self):
        return self.command.run_ludus('power on', self.path, self.api_key)

    def stop(self):
        return self.command.run_ludus('power off', self.path, self.api_key)

    def status(self):
        return self.command.run_ludus('range status', self.path, self.api_key)

    def destroy_vm(self, vm_name):
        # not implemented
        pass

    def start_vm(self, vm_name):
        return self.command.run_ludus(f'power on -n {vm_name}', self.path, self.api_key)

    def stop_vm(self, vm_name):
        return self.command.run_ludus(f'power off -n {vm_name}', self.path, self.api_key)
