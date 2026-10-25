from goad.provider.provider import Provider
from goad.command.cmd_factory import CommandFactory
from goad.utils import *
from goad.log import Log
import json
import time


def _get_ludus_major_version(config):
    """Run `ludus version` and return the major version number (1 or 2).

    Falls back to the LUDUS_VERSION env var, then defaults to 1.
    """
    if 'LUDUS_VERSION' in os.environ:
        return int(os.environ['LUDUS_VERSION'])
    api_key = config.get_value('ludus', 'ludus_api_key', 'not_set')
    command = CommandFactory.get_command()
    if command.on_ludus():
        output = command.run_ludus_result(['version', '--json'], None, api_key, do_log=False)
        if not output:
            return 1
        try:
            version_json = json.loads(output)
            version = version_json.get('version', '')
            if version:
                return int(version.split('.')[0])
        except (json.JSONDecodeError, KeyError, ValueError):
            pass
    return 1


class LudusProvider(Provider):
    provider_name = LUDUS
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER]
    update_ip_range = True

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        self.api_key = config.get_value('ludus', 'ludus_api_key', 'not_set')
        self.use_impersonation = config.get_value('ludus', 'use_impersonation', 'no') == 'yes'
        self.lab_user = 'GOAD'
        self.major_version = _get_ludus_major_version(config)
        self.range_id = config.get_value('ludus', 'range_id', 'None')
        self._get_default_range()
        if not self.use_impersonation and self.major_version >= 2 and self.default_range is None:
            Log.error('User has no default range ID set, and is not using impersonation. Use impersonation or set a specific range ID. ' + 
                      'A user requires a default range for GOAD or a specific range ID must be set with Ludus v2')
            
    def _user_command(self, args):
        """Build a user-related command list, adding the v1 URL prefix when needed."""
        if self.major_version < 2:
            return ['--url', 'https://127.0.0.1:8081'] + args
        return args

    def _get_default_range(self):
        """Get the default range ID for the user, if it exists."""
        if self.major_version >= 2:
            command = self._user_command(['range', 'default', 'get', '--json'])
            default = self.command.run_ludus_result(command, None, self.api_key, do_log=False)
            if default != '':
                default = json.loads(default)
                self.default_range = default['defaultRangeID']
            else:
                Log.warning('User has no default range ID')
                self.default_range = None
            #Log.info(f"Default range ID is {self.default_range}")
        else:
            self.default_range = None

    def _get_range_id(self):
        """Determine the range ID to use for deployment, based on config and user defaults."""
        if self.major_version >= 2:
            if str.lower(self.range_id) == 'none' or self.range_id == '':
                Log.info('Range ID is not set, falling back to default rangeID')
                self.range_id = self.default_range
            else:
                Log.info(f"Range ID is set, using {self.range_id} as range ID")
                self.range_id = self.range_id            
        else:
            self.range_id = None

    def set_lab_user(self, lab_user):
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
                command = self._user_command(['user', 'list', '--json'])
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
        Log.info(f"Using Ludus {self.major_version} provider")
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
        command = self._user_command(['user', 'list', 'all', '--json'])
        ludus_users = self.command.run_ludus_result(command, self.path, self.api_key)
        users = json.loads(ludus_users)
        for user in users:
            if user['userID'] == user_to_test:
                Log.success(f'User {user_to_test} already exist')
                user_exist = True
                break
        return user_exist

    def _create_user(self):
        """Create the lab user via the ludus CLI."""
        if self.major_version >= 2:
            password = ''.join(random.choices(string.ascii_letters + string.digits, k=12))
            command = self._user_command([
                'user', 'add', '-n', self.lab_user, '-i', self.lab_user,
                '-e', f'{self.lab_user}@ludus.internal', '-p', password,
            ])
        else:
            command = self._user_command([
                'user', 'add', '-n', self.lab_user, '-i', self.lab_user,
            ])
        self.command.run_ludus_result(command, self.path, self.api_key)
        Log.info('Lab user created')

    def _grant_access(self, current_ludus_user):
        """Grant the admin user access to the lab range after deployment."""
        Log.info(f'Add access to lab range {self.lab_user} for your user {current_ludus_user}')
        if self.major_version >= 2:
            self.command.run_ludus(
                f'range assign {current_ludus_user} {self.lab_user}',
                self.path, self.api_key,
            )
        else:
            self.command.run_ludus(
                f'range access grant --target {self.lab_user} --source {current_ludus_user}',
                self.path, self.api_key,
            )

    def install(self):
        self._get_range_id()
        
        # In edge cases a user might not have a default range. Thus checking for the edgecase.
        if self.default_range is None and self.range_id is None and not self.use_impersonation and self.major_version >= 2:
            Log.error('User has no default range ID set, and no range ID specified. Range ID or a default range must be set if not using impersonation with Ludus v2')
            return False
        if self.range_id is not None:
            Log.info(f'Using range ID {self.range_id} for deployment')
            command = self._user_command(['range', 'list', 'all', '--json'])
            ranges = self.command.run_ludus_result(command, None, self.api_key, do_log=False)
            exists = False
            for range in json.loads(ranges):
                if range['rangeID'] == self.range_id:
                    Log.info(f'Range ID {self.range_id} exist, continue deployment')
                    exists = True
                    break
            if not exists:
                Log.info(f'Range ID {self.range_id} does not exist, creating it')
                command = self._user_command(['range', 'create', '-r', self.range_id, '-n', self.range_id, '--json'])
                self.command.run_ludus_result(command, None, self.api_key, do_log=False)
            
            Log.info(f'Setting default range ID to {self.range_id} for deployment')
            command = self._user_command(['range', 'default', 'set', '-r', self.range_id, '--json'])
            self.command.run_ludus_result(command, None, self.api_key, do_log=False)
            
                    
        current_ludus_user = ''
        if self.use_impersonation and self.range_id is None:
            current_ludus_user = self.get_ludus_user()
            if current_ludus_user is None:
                return False

            if not self.user_exist(self.lab_user):
                Log.info('Lab user does not exist create it')
                self._create_user()

            if not self.user_exist(self.lab_user):
                Log.error('Lab user creation error')
                return False

        set_config_result = self.command.run_ludus(
            f'range config set -f config.yml', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )
        if not set_config_result:
            return False

        deploy_result = self.command.run_ludus(
            f'range deploy', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )
        if not deploy_result:
            return False

        while True:
            command = ['range', 'status', '--json']
            ludus_status = self.command.run_ludus_result(
                command, self.path, self.api_key,
                do_log=False, user_id=self.lab_user, impersonation=self.use_impersonation,
            )
            if ludus_status is None:
                return False
            try:
                range_status = json.loads(ludus_status)
                range_state = range_status['rangeState']
                if range_state == 'ERROR':
                    Log.error('Error during deployment')
                    self.command.run_ludus(
                        'range errors', self.path, self.api_key,
                        self.lab_user, self.use_impersonation,
                    )
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

        if self.use_impersonation and self.range_id is None:
            self._grant_access(current_ludus_user)
            
        if self.range_id is not None and self.default_range is not None:
            Log.info(f'Setting default range ID back to {self.default_range} for deployment')
            command = self._user_command(['range', 'default', 'set', '-r', self.default_range, '--json'])
            self.command.run_ludus_result(command, None, self.api_key, do_log=False)
        return True

    def get_ip_range(self):
        try:
            command = ['range', 'status', '--json']
            ludus_status = self.command.run_ludus_result(
                command, self.path, self.api_key,
                do_log=True, user_id=self.lab_user, impersonation=self.use_impersonation,
            )
            range_status = json.loads(ludus_status)
            range_number = range_status['rangeNumber']
            Log.info(f'Ludus ip range : {range_number}')
            return f'10.{range_number}.10'
        except Exception as e:
            Log.error('Error during ludus status')
            return None

    def destroy(self):
        return self.command.run_ludus(
            f'range rm', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )

    def start(self):
        return self.command.run_ludus(
            f'power on -n all', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )

    def stop(self):
        return self.command.run_ludus(
            f'power off -n all', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )

    def status(self):
        return self.command.run_ludus(
            f'range status', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )

    def destroy_vm(self, vm_name):
        if self.major_version < 2:
            Log.error('Not implemented for Ludus v1')
            return False
        status = self.command.run_ludus(
            f'range status --json', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )
        if status is None:
            return False
        status_json = json.loads(status)
        for vm in status_json['VMs']:
            if vm['name'] == vm_name:
                vm_id = vm['proxmoxID']
                break
        return self.command.run_ludus(
            f'vm destroy {vm_id} --no-prompt', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )

    def start_vm(self, vm_name):
        return self.command.run_ludus(
            f'power on -n {vm_name}', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )

    def stop_vm(self, vm_name):
        return self.command.run_ludus(
            f'power off -n {vm_name}', self.path, self.api_key,
            self.lab_user, self.use_impersonation,
        )
