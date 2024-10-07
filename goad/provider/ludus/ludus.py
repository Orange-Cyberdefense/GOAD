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
        self.api_key = config.get_value('ludus', 'ludus_api_key', 'not_set')
        if config.get_value('ludus', 'use_impersonation', 'no') == 'yes':
            self.use_impersonation = True
        else:
            self.use_impersonation = False
        self.lab_user = 'GOAD'

    def set_lab_user(self, lab_user):
        # user is <LAB>-<randomid>
        if self.use_impersonation:
            self.lab_user = lab_user

    def get_ludus_user(self):
        ludus_user = None
        ludus_version = self.command.run_ludus_result(["version"], self.path, self.api_key)
        if ludus_version is None:
            Log.error('Error to contact ludus.')
            return None
        if 'No API key loaded' in ludus_version:
            Log.error('Please add the ludus api key to HOME/.goad/goad.ini file')
        else:
            Log.success('Api key is set')
            if self.use_impersonation:
                command = ['--url', 'https://127.0.0.1:8081', 'user', 'list', '--json']
                ludus_users = self.command.run_ludus_result(command, self.path, self.api_key)
                print(ludus_users)
                users = json.loads(ludus_users)
                if len(users) > 0:
                    Log.info(f'Current user name : {users[0]["name"]}')
                    Log.info(f'Current user ID   : {users[0]["userID"]}')
                    Log.info(f'User is admin     : {users[0]["isAdmin"]}')
                    if not users[0]["isAdmin"]:
                        Log.error('User must be admin')
                    else:
                        ludus_user = users[0]["userID"]
            else:
                ludus_user = 'ok'
        return ludus_user

    def check(self):
        check = super().check()
        check_ludus = self.command.check_ludus()
        if check_ludus:
            current_ludus_user = self.get_ludus_user()
            if current_ludus_user is not None:
                check_ludus = True

        checks = [
            self.command.check_disk(),
            self.command.check_ram(),
            self.command.check_ansible()
        ]
        return check and check_ludus and all(checks)

    def user_exist(self, user_to_test):
        user_exist = False
        command = ['--url', 'https://127.0.0.1:8081', 'user', 'list', 'all', '--json']
        ludus_users = self.command.run_ludus_result(command, self.path, self.api_key)
        users = json.loads(ludus_users)
        for user in users:
            if user['userID'] == user_to_test:
                Log.success(f'User {user_to_test} already exist')
                user_exist = True
                break
        return user_exist

    def install(self):
        current_ludus_user = ''
        if self.use_impersonation:
            # check current ludus user
            current_ludus_user = self.get_ludus_user()
            if current_ludus_user is None:
                return False

            # check ludus user exist
            if not self.user_exist(self.lab_user):
                Log.info('Lab user does not exist create it')
                command = ['--url', 'https://127.0.0.1:8081', 'user', 'add', '-n', self.lab_user, '-i', self.lab_user]
                user_creation = self.command.run_ludus_result(command, self.path, self.api_key)
                Log.info('Lab user created')

            if not self.user_exist(self.lab_user):
                Log.error('Lab user creation error')
                return False

        set_config_result = self.command.run_ludus(f'range config set -f config.yml', self.path, self.api_key, self.lab_user, self.use_impersonation)
        if not set_config_result:
            return False

        deploy_result = self.command.run_ludus(f'range deploy', self.path, self.api_key, self.lab_user, self.use_impersonation)
        if not deploy_result:
            return False

        while True:
            command = ['range', 'status', '--json']
            ludus_status = self.command.run_ludus_result(command, self.path, self.api_key, do_log=False, user_id=self.lab_user, impersonation=self.use_impersonation)
            if ludus_status is None:
                return False
            try:
                range_status = json.loads(ludus_status)
                range_state = range_status['rangeState']
                if range_state == 'ERROR':
                    Log.error('Error during deployment')
                    self.command.run_ludus('range errors', self.path, self.api_key, self.lab_user, self.use_impersonation)
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

        if self.use_impersonation:
            # deployment finish add grant access to our user
            Log.info(f'Add access to lab range {self.lab_user} for your user {current_ludus_user}')
            self.command.run_ludus(f'range access grant --target {self.lab_user} --source {current_ludus_user}', self.path, self.api_key)
        return True

    def get_ip_range(self):
        try:
            command = ['range', 'status', '--json']
            ludus_status = self.command.run_ludus_result(command, self.path, self.api_key, do_log=True, user_id=self.lab_user, impersonation=self.use_impersonation)
            range_status = json.loads(ludus_status)
            range_number = range_status['rangeNumber']
            Log.info(f'Ludus ip range : {range_number}')
            return f'10.{range_number}.10'
        except Exception as e:
            Log.error('Error during ludus status')
            return None

    def destroy(self):
        return self.command.run_ludus(f'range rm', self.path, self.api_key, self.lab_user, self.use_impersonation)

    def start(self):
        return self.command.run_ludus(f'power on -n all', self.path, self.api_key, self.lab_user, self.use_impersonation)

    def stop(self):
        return self.command.run_ludus(f'power off -n all', self.path, self.api_key, self.lab_user, self.use_impersonation)

    def status(self):
        return self.command.run_ludus(f'range status', self.path, self.api_key, self.lab_user, self.use_impersonation)

    def destroy_vm(self, vm_name):
        Log.error('Not implememnted')
        return False

    def start_vm(self, vm_name):
        return self.command.run_ludus(f'power on -n {vm_name}', self.path, self.api_key, self.lab_user, self.use_impersonation)

    def stop_vm(self, vm_name):
        return self.command.run_ludus(f'power off -n {vm_name}', self.path, self.api_key, self.lab_user, self.use_impersonation)
