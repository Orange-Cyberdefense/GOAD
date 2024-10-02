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
        # TODO
        return True

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
