import json
import os
import subprocess
import time

from huaweicloudsdkcore.auth.credentials import BasicCredentials
from huaweicloudsdkcore.region.region import Region
from huaweicloudsdkecs.v2 import (
    BatchStartServersOption,
    BatchStartServersRequest,
    BatchStartServersRequestBody,
    BatchStopServersOption,
    BatchStopServersRequest,
    BatchStopServersRequestBody,
    DeleteServersRequest,
    DeleteServersRequestBody,
    EcsClient,
    ListServersDetailsRequest,
    ServerId,
)
from rich import print
from rich.table import Table

from goad.exceptions import *
from goad.log import Log
from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class CloudruProvider(TerraformProvider):
    provider_name = CLOUDRU
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        self.resource_group = lab_name
        self.jumpbox_setup_script = 'setup_cloudru.sh'
        self.region = config.get_value('cloudru', 'cloudru_region', 'ru-moscow-1')
        self.iam_endpoint = config.get_value(
            'cloudru',
            'cloudru_iam_endpoint',
            f'https://iam.{self.region}.hc.sbercloud.ru/v3'
        )
        self.ecs_endpoint = config.get_value(
            'cloudru',
            'cloudru_ecs_endpoint',
            f'https://ecs.{self.region}.hc.sbercloud.ru'
        )

    def _auth(self):
        ak = os.getenv('SBC_ACCESS_KEY')
        sk = os.getenv('SBC_SECRET_KEY')
        security_token = os.getenv('SBC_SECURITY_TOKEN')
        project_id = os.getenv('SBC_PROJECT_ID') or os.getenv('OS_PROJECT_ID')

        if not ak or not sk or not security_token:
            raise AuthenticationFailed(
                'Missing SBC_ACCESS_KEY, SBC_SECRET_KEY, or SBC_SECURITY_TOKEN environment variable'
            )

        creds = BasicCredentials(ak, sk, project_id).with_iam_endpoint(self.iam_endpoint)
        creds = creds.with_security_token(security_token)

        region = Region(self.region, self.ecs_endpoint)

        return creds, region

    def _ecs_client(self):
        creds, region = self._auth()
        return EcsClient.new_builder() \
            .with_credentials(creds) \
            .with_region(region) \
            .build()

    @staticmethod
    def _get_attr(obj, name, default=None):
        if isinstance(obj, dict):
            return obj.get(name, default)
        return getattr(obj, name, default)

    @staticmethod
    def _color_vm_state(state):
        if state == 'ACTIVE':
            return f'[green]{state}[/green]'
        if state == 'SHUTOFF':
            return f'[red]{state}[/red]'
        return f'[yellow]{state}[/yellow]'

    @staticmethod
    def _server_ips(server):
        public_ips = []
        private_ips = []
        addresses = CloudruProvider._get_attr(server, 'addresses', {}) or {}
        for network_addresses in addresses.values():
            for address in network_addresses:
                ip = CloudruProvider._get_attr(address, 'addr', '')
                ip_type = CloudruProvider._get_attr(address, 'OS-EXT-IPS:type', '')
                if not ip:
                    continue
                if ip_type == 'floating':
                    public_ips.append(ip)
                else:
                    private_ips.append(ip)
        return public_ips, private_ips

    def _terraform_output_json(self, output_name):
        try:
            result = subprocess.run(
                [self.command.terraform_bin, 'output', '-json', output_name],
                cwd=self.path,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
        except Exception as e:
            Log.error(f'Error running terraform output for {output_name}: {e}')
            return None
        if result.returncode != 0:
            Log.error(f'Error reading terraform output {output_name}: {result.stderr}')
            return None

        try:
            return json.loads(result.stdout)
        except json.JSONDecodeError:
            Log.error(f'Invalid terraform JSON output for {output_name}')
            return None

    def _expected_private_ips(self):
        expected_ips = set()
        for output_name in ['vm-config', 'linux-vm-config']:
            vm_config = self._terraform_output_json(output_name)
            if not vm_config:
                continue
            for vm in vm_config.values():
                ip = vm.get('private_ip_address')
                if ip:
                    expected_ips.add(ip)
        return expected_ips

    def _expected_names(self):
        names = set()
        name_prefix = None
        if self.path:
            variables_file = os.path.join(self.path, 'variables.tf')
            if os.path.isfile(variables_file):
                with open(variables_file, 'r', encoding='utf-8') as variables:
                    for line in variables:
                        line = line.strip()
                        if line.startswith('default') and 'GOAD-' in line and name_prefix is None:
                            name_prefix = line.split('=', 1)[1].strip().strip('"')
                            break
        if not name_prefix:
            name_prefix = f'GOAD-{self.lab_name}'
        names.add(f'{name_prefix}-jumpbox-ubuntu')
        for output_name in ['vm-config', 'linux-vm-config']:
            vm_config = self._terraform_output_json(output_name)
            if not vm_config:
                continue
            for vm in vm_config.values():
                name = vm.get('name')
                if name:
                    names.add(f'{name_prefix}-{name}')
        return names

    def _list_servers(self):
        try:
            client = self._ecs_client()
            request = ListServersDetailsRequest(limit=1000)
            response = client.list_servers_details(request)
        except Exception as e:
            Log.error(f'Error retrieving CloudRU ECS instances: {e}')
            return []

        servers = self._get_attr(response, 'servers', []) or []
        expected_names = self._expected_names()
        expected_private_ips = self._expected_private_ips()
        lab_servers = []
        for server in servers:
            name = self._get_attr(server, 'name', '')
            _, private_ips = self._server_ips(server)
            if name in expected_names or any(ip in expected_private_ips for ip in private_ips):
                lab_servers.append(server)
        return lab_servers

    def _find_servers(self, vm_name=None):
        servers = self._list_servers()
        if vm_name is None:
            return servers

        found = []
        for server in servers:
            server_id = self._get_attr(server, 'id', '')
            name = self._get_attr(server, 'name', '')
            short_name = name.split('-')[-1]
            if vm_name in [server_id, name, short_name]:
                found.append(server)
        return found

    def _wait_vm_status(self, vm_name, expected_status, timeout=600, interval=15):
        deadline = time.time() + timeout
        while time.time() < deadline:
            servers = self._find_servers(vm_name)
            if not servers:
                Log.error(f'vm {vm_name} not found')
                return False
            statuses = [self._get_attr(server, 'status', 'UNKNOWN') for server in servers]
            if all(status == expected_status for status in statuses):
                return True
            Log.info(
                f'Waiting for {vm_name} to reach {expected_status}, current status: {", ".join(statuses)}'
            )
            time.sleep(interval)
        Log.error(f'Timeout waiting for {vm_name} to reach {expected_status}')
        return False

    @staticmethod
    def _server_ids(servers):
        return [ServerId(id=CloudruProvider._get_attr(server, 'id')) for server in servers]

    def _batch_action(self, action, servers):
        if not servers:
            Log.error('No CloudRU ECS instances found')
            return False

        client = self._ecs_client()
        server_ids = self._server_ids(servers)
        try:
            if action == 'start':
                request = BatchStartServersRequest(
                    body=BatchStartServersRequestBody(
                        os_start=BatchStartServersOption(servers=server_ids)
                    )
                )
                client.batch_start_servers(request)
            elif action == 'stop':
                request = BatchStopServersRequest(
                    body=BatchStopServersRequestBody(
                        os_stop=BatchStopServersOption(servers=server_ids, type='SOFT')
                    )
                )
                client.batch_stop_servers(request)
            elif action == 'delete':
                request = DeleteServersRequest(
                    body=DeleteServersRequestBody(
                        delete_publicip=True,
                        delete_volume=True,
                        servers=server_ids
                    )
                )
                client.delete_servers(request)
            else:
                Log.error(f'Unsupported CloudRU action: {action}')
                return False
        except Exception as e:
            Log.error(f'CloudRU {action} action failed: {e}')
            return False

        Log.info(f'CloudRU {action} action requested for {len(servers)} VM(s)')
        return True

    def check(self):
        # check terraform bin
        check = super().check()
        try:
            self._auth()
            self._ecs_client().list_servers_details(ListServersDetailsRequest(limit=1))
            Log.success('CloudRU SDK authentication configured')
        except AuthenticationFailed as e:
            Log.error(e)
            check = False
        except Exception as e:
            Log.error(f'CloudRU SDK authentication error: {e}')
            check = False

        return check

    def start(self):
        return self._batch_action('start', self._find_servers())

    def stop(self):
        return self._batch_action('stop', self._find_servers())

    def status(self):
        table = Table()
        table.add_column('VM Id')
        table.add_column('Name')
        table.add_column('Location')
        table.add_column('PowerState')
        table.add_column('PublicIP')
        table.add_column('PrivateIP')

        for server in self._list_servers():
            public_ips, private_ips = self._server_ips(server)
            table.add_row(
                self._get_attr(server, 'id', ''),
                self._get_attr(server, 'name', ''),
                self._get_attr(server, 'availability_zone', self.region),
                self._color_vm_state(self._get_attr(server, 'status', 'UNKNOWN')),
                ','.join(public_ips),
                ','.join(private_ips)
            )
        print(table)
        return True

    def start_vm(self, vm_name):
        servers = self._find_servers(vm_name)
        found = self._batch_action('start', servers)
        if not found:
            Log.error(f'vm {vm_name} not found')
            return False
        return self._wait_vm_status(vm_name, 'ACTIVE')

    def stop_vm(self, vm_name):
        servers = self._find_servers(vm_name)
        found = self._batch_action('stop', servers)
        if not found:
            Log.error(f'vm {vm_name} not found')
            return False
        return self._wait_vm_status(vm_name, 'SHUTOFF')

    def destroy_vm(self, vm_name):
        servers = self._find_servers(vm_name)
        found = self._batch_action('delete', servers)
        if not found:
            Log.error(f'vm {vm_name} not found')
        return found

    def ssh_jumpbox(self):
        jumpbox_ip = self.get_jumpbox_ip()
        if jumpbox_ip is None:
            return False
        ssh_key = os.path.join(os.path.dirname(self.path), 'ssh_keys', 'ubuntu-jumpbox.pem')
        ssh_cmd = f'ssh -o StrictHostKeyChecking=no -i {ssh_key} goad@{jumpbox_ip}'
        self.command.run_shell(ssh_cmd, self.path)
        return True

    def get_jumpbox_ip(self, ip_range=''):
        jumpbox_ip = self.command.run_terraform_output(['ubuntu-jumpbox-ip'], self.path)
        if jumpbox_ip is None:
            Log.error('Jump box ip not found')
            return None
        if not Utils.is_valid_ipv4(jumpbox_ip):
            Log.error('Invalid IP')
            return None
        return jumpbox_ip
