import json
import getpass
import os
import shlex
import ipaddress
import subprocess
import time
from pathlib import Path
from urllib.parse import quote

from goad.provider.provider import Provider
from goad.log import Log
from goad.utils import *


class VsphereProvider(Provider):
    provider_name = VSPHERE
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners = [PROVISIONING_LOCAL, PROVISIONING_RUNNER, PROVISIONING_DOCKER]

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        self.server = config.get_value('vsphere', 'vsphere_server', config.get_value('vmware_esxi', 'esxi_hostname', ''))
        self.username = config.get_value('vsphere', 'vsphere_user', config.get_value('vmware_esxi', 'esxi_username', ''))
        self.password = config.get_value('vsphere', 'vsphere_password', config.get_value('vmware_esxi', 'esxi_password', ''))
        self.datastore = config.get_value('vsphere', 'vsphere_datastore', config.get_value('vmware_esxi', 'esxi_datastore', ''))
        self.network = config.get_value('vsphere', 'vsphere_network', config.get_value('vmware_esxi', 'esxi_net_domain', ''))
        self.ovftool_target = config.get_value('vsphere', 'vsphere_ovftool_target', '')
        self.vm_folder = config.get_value('vsphere', 'vsphere_folder', '')
        self.resource_pool = config.get_value('vsphere', 'vsphere_resource_pool', '')
        self.disk_mode = config.get_value('vsphere', 'vsphere_disk_mode', 'thin')
        self.no_ssl_verify = config.get_value('vsphere', 'vsphere_allow_unverified_ssl', 'true').lower() == 'true'
        self.overwrite = config.get_value('vsphere', 'vsphere_overwrite', 'false').lower() == 'true'
        self.box_provider = config.get_value('vsphere', 'vsphere_box_provider', 'vmware_desktop')
        self.vm_name_prefix = config.get_value('vsphere', 'vsphere_vm_name_prefix', '')
        self.ovftool_bin = config.get_value('vsphere', 'vsphere_ovftool_bin', 'ovftool')
        self.govc_bin = config.get_value('vsphere', 'vsphere_govc_bin', 'govc')
        self.network_adapter = config.get_value('vsphere', 'vsphere_network_adapter', 'e1000')
        self.bootstrap_guest_network = config.get_value('vsphere', 'vsphere_bootstrap_guest_network', 'true').lower() == 'true'
        self.guest_username = config.get_value('vsphere', 'vsphere_guest_username', 'vagrant')
        self.guest_password = config.get_value('vsphere', 'vsphere_guest_password', 'vagrant')
        self.ipv4_prefix_length = config.get_value('vsphere', 'vsphere_ipv4_prefix_length', '27')
        self.ipv4_gateway = config.get_value('vsphere', 'vsphere_ipv4_gateway', '')
        self.dns_server = config.get_value('vsphere', 'vsphere_dns_server', '')

    def check(self):
        checks = [
            self.command.check_vagrant(),
            self.command.check_ovftool(),
            self.command.check_govc(),
            self.command.check_ansible()
        ]
        return all(checks)

    @staticmethod
    def _url_quote(value):
        return quote(value, safe='')

    def _password_needs_prompt(self):
        if self.password is None:
            return True
        return self.password.strip() == '' or self.password == 'password'

    def _ensure_password(self):
        if not self._password_needs_prompt():
            return self.password

        env_password = os.environ.get('VSPHERE_PASSWORD') or os.environ.get('GOVC_PASSWORD')
        if env_password:
            self.password = env_password
            return self.password

        self.password = getpass.getpass(f'Enter vSphere password for {self.username}@{self.server}: ')
        return self.password

    @staticmethod
    def _sanitize_vi_locator(value):
        if not value.startswith('vi://'):
            return value

        body = value[len('vi://'):]
        authority, separator, path = body.partition('/')
        if '@' not in authority:
            return value

        host = authority.rsplit('@', 1)[1]
        return f'vi://***@{host}{separator}{path}'

    def _sanitize_command(self, command):
        sanitized = []
        for arg in command:
            if self.password:
                arg = arg.replace(self.password, '***')
                arg = arg.replace(self._url_quote(self.password), '***')
            if self.username:
                arg = arg.replace(self._url_quote(self.username), '***')
            if self.guest_password and arg != self.command.vagrant_bin:
                arg = arg.replace(self.guest_password, '***')
                arg = arg.replace(self._url_quote(self.guest_password), '***')
            arg = self._sanitize_vi_locator(arg)
            sanitized.append(arg)
        return sanitized

    def _log_command(self, command):
        sanitized = self._sanitize_command(command)
        Log.info('CWD: ' + Utils.get_relative_path(str(self.path)))
        Log.cmd(' '.join(shlex.quote(arg) for arg in sanitized))

    def _run(self, command, env=None):
        self._log_command(command)
        result = subprocess.run(command, cwd=self.path, env=env)
        return result.returncode == 0

    def _capture(self, command, env=None):
        self._log_command(command)
        result = subprocess.run(command, cwd=self.path, env=env, capture_output=True, text=True)
        if result.returncode != 0:
            if result.stdout:
                Log.basic(result.stdout.strip())
            if result.stderr:
                Log.error(result.stderr.strip())
            return None
        return result.stdout

    def _govc_env(self):
        password = self._ensure_password()
        env = os.environ.copy()
        env['GOVC_URL'] = self.server
        env['GOVC_USERNAME'] = self.username
        env['GOVC_PASSWORD'] = password
        env['GOVC_INSECURE'] = '1' if self.no_ssl_verify else '0'
        if self.datastore:
            env['GOVC_DATASTORE'] = self.datastore
        if self.network:
            env['GOVC_NETWORK'] = self.network
        if self.resource_pool:
            env['GOVC_RESOURCE_POOL'] = self.resource_pool
        if self.vm_folder:
            env['GOVC_FOLDER'] = self.vm_folder
        return env

    def _run_govc(self, args):
        return self._run([self.govc_bin] + args, self._govc_env())

    def _capture_govc(self, args):
        return self._capture([self.govc_bin] + args, self._govc_env())

    def _run_govc_retry(self, args, tries=30, delay=10):
        for attempt in range(1, tries + 1):
            if self._run_govc(args):
                return True
            if attempt < tries:
                Log.info(f'govc command failed, retry in {delay}s ({attempt}/{tries})')
                time.sleep(delay)
        return False

    def _instance_id(self):
        return Path(self.path).parent.name

    def _vm_prefix(self):
        if self.vm_name_prefix:
            return self.vm_name_prefix
        return self._instance_id()

    def _vm_name(self, box):
        return f'{self._vm_prefix()}-{box["name"]}'

    def _target_url(self):
        password = self._ensure_password()
        if self.ovftool_target:
            if self.ovftool_target.startswith('vi://'):
                return self.ovftool_target
            target = self.ovftool_target.strip('/')
            return f'vi://{self._url_quote(self.username)}:{self._url_quote(password)}@{self.server}/{target}'
        return f'vi://{self._url_quote(self.username)}:{self._url_quote(password)}@{self.server}/'

    @staticmethod
    def _range_from_ip(ip):
        parts = ip.split('.')
        if len(parts) == 4:
            return '.'.join(parts[:3])
        return ''

    def _gateway_for_box(self, box):
        if self.ipv4_gateway:
            return self.ipv4_gateway
        ip_range = self._range_from_ip(box['ip'])
        if ip_range:
            return ip_range + '.1'
        return ''

    def _dns_for_box(self, box):
        if self.dns_server:
            return self.dns_server
        return self._gateway_for_box(box)

    def _guest_login(self):
        return f'{self.guest_username}:{self.guest_password}'

    @staticmethod
    def _netmask_from_prefix(prefix_length):
        return str(ipaddress.IPv4Network(f'0.0.0.0/{prefix_length}').netmask)

    def _bootstrap_windows_guest(self, vm_name, box):
        configure_script = Path(project_path) / 'vagrant' / 'ConfigureRemotingForAnsible.ps1'
        remote_configure_script = 'C:\\Windows\\Temp\\ConfigureRemotingForAnsible.ps1'
        if not self._run_govc_retry([
            'guest.upload',
            '-vm', vm_name,
            '-l', self._guest_login(),
            str(configure_script),
            remote_configure_script
        ], tries=12, delay=10):
            return False

        if not self._run_govc_retry([
            'guest.start',
            '-vm', vm_name,
            '-l', self._guest_login(),
            'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe',
            '-ExecutionPolicy', 'Bypass',
            '-File', remote_configure_script,
            '-SkipNetworkProfileCheck'
        ], tries=3, delay=10):
            return False

        gateway = self._gateway_for_box(box)
        dns_server = self._dns_for_box(box)
        netmask = self._netmask_from_prefix(self.ipv4_prefix_length)
        command = (
            'for /f "skip=3 tokens=1,2,3,*" %a in ('
            "'netsh interface show interface'"
            f') do if /I "%b"=="Connected" ('
            f'netsh interface ipv4 set address name="%d" static {box["ip"]} {netmask} {gateway} 1 & '
            f'netsh interface ipv4 set dnsservers name="%d" static {dns_server} primary'
            ')'
        )
        return self._run_govc_retry([
            'guest.start',
            '-vm', vm_name,
            '-l', self._guest_login(),
            'C:\\Windows\\System32\\cmd.exe',
            '/c', command
        ], tries=6, delay=10)

    def _bootstrap_linux_guest(self, vm_name, box):
        gateway = self._gateway_for_box(box)
        dns_server = self._dns_for_box(box)
        script = (
            "set -e; "
            "iface=$(ip -o link show | awk -F': ' '$2 != \"lo\" {print $2; exit}'); "
            f"sudo ip addr flush dev \"$iface\"; "
            f"sudo ip addr add {box['ip']}/{self.ipv4_prefix_length} dev \"$iface\"; "
            "sudo ip link set \"$iface\" up; "
            f"sudo ip route replace default via {gateway}; "
            f"echo nameserver {dns_server} | sudo tee /etc/resolv.conf >/dev/null"
        )
        return self._run_govc_retry([
            'guest.start',
            '-vm', vm_name,
            '-l', self._guest_login(),
            '/bin/bash',
            '-lc', script
        ], tries=30, delay=10)

    def _bootstrap_guest(self, vm_name, box):
        if not self.bootstrap_guest_network:
            return True
        os_name = box.get('os', '').lower()
        Log.info(f'Bootstrap guest network for {vm_name} ({box["ip"]}/{self.ipv4_prefix_length})')
        if os_name == 'windows':
            return self._bootstrap_windows_guest(vm_name, box)
        return self._bootstrap_linux_guest(vm_name, box)

    def _network_devices(self, vm_name):
        output = self._capture_govc(['device.ls', '-vm', vm_name])
        if output is None:
            return []

        devices = []
        for line in output.splitlines():
            fields = line.split()
            if not fields:
                continue
            device = fields[0]
            if device.lower().startswith('ethernet-') and device not in devices:
                devices.append(device)
        return devices

    def _add_network_device(self, vm_name):
        if not self.network:
            Log.error(f'No ethernet devices found on {vm_name} and vsphere_network is empty')
            return False

        Log.info(f'Add network adapter to {vm_name} on {self.network}')
        args = ['vm.network.add', '-vm', vm_name, '-net', self.network]
        if self.network_adapter:
            args += ['-net.adapter', self.network_adapter]
        return self._run_govc(args)

    def _connect_network_devices(self, vm_name):
        devices = self._network_devices(vm_name)
        if not devices:
            Log.warning(f'No ethernet devices found on {vm_name}; creating one')
            if not self._add_network_device(vm_name):
                return False
            devices = self._network_devices(vm_name)
            if not devices:
                Log.error(f'No ethernet devices found on {vm_name} after adding one')
                return False

        result = True
        for device in devices:
            if self.network:
                Log.info(f'Set {vm_name} {device} network to {self.network}')
                result = self._run_govc(['vm.network.change', '-vm', vm_name, '-net', self.network, device]) and result
            Log.info(f'Connect {vm_name} {device}')
            result = self._run_govc(['device.connect', '-vm', vm_name, device]) and result
        return result

    def _get_boxes(self):
        boxes_file = Path(self.path) / 'boxes.json'
        if not boxes_file.is_file():
            Log.error(f'boxes manifest not found: {boxes_file}')
            return []
        with open(boxes_file, 'r') as box_file:
            return json.load(box_file)

    def _vagrant_box_root(self, box):
        box_root_name = box['box'].replace('/', '-VAGRANTSLASH-')
        return Path.home() / '.vagrant.d' / 'boxes' / box_root_name

    def _find_box_provider_dir(self, box):
        box_root = self._vagrant_box_root(box)
        version = str(box.get('box_version', '')).strip()
        candidates = []
        if version:
            candidates.append(box_root / version / self.box_provider)
        if box_root.is_dir():
            for provider_dir in box_root.glob(f'*/{self.box_provider}'):
                candidates.append(provider_dir)
            for provider_dir in box_root.glob('*/vmware*'):
                candidates.append(provider_dir)

        for candidate in candidates:
            if candidate.is_dir():
                return candidate
        return None

    def _ensure_box(self, box):
        provider_dir = self._find_box_provider_dir(box)
        if provider_dir is not None:
            return provider_dir

        command = [self.command.vagrant_bin, 'box', 'add', box['box'], '--provider', self.box_provider]
        if box.get('box_version'):
            command += ['--box-version', str(box['box_version'])]
        if not self._run(command):
            return None
        return self._find_box_provider_dir(box)

    @staticmethod
    def _find_box_source(provider_dir):
        for extension in ('*.ovf', '*.ova', '*.vmx'):
            matches = list(provider_dir.rglob(extension))
            if matches:
                return matches[0]
        return None

    def _deploy_box(self, box):
        provider_dir = self._ensure_box(box)
        if provider_dir is None:
            Log.error(f'Unable to find or download vagrant box {box["box"]}')
            return False

        source = self._find_box_source(provider_dir)
        if source is None:
            Log.error(f'No OVF/OVA/VMX source found in {provider_dir}')
            return False

        vm_name = self._vm_name(box)
        command = [
            self.ovftool_bin,
            '--acceptAllEulas',
            '--allowExtraConfig',
            f'--name={vm_name}',
            f'--datastore={self.datastore}',
            f'--diskMode={self.disk_mode}',
            f'--network={self.network}',
        ]
        if self.no_ssl_verify:
            command.append('--noSSLVerify')
        if self.overwrite:
            command += ['--overwrite', '--powerOffTarget']
        if self.vm_folder:
            command.append(f'--vmFolder={self.vm_folder}')
        command += [str(source), self._target_url()]

        if not self._run(command):
            return False

        if box.get('cpus') or box.get('mem'):
            args = ['vm.change', '-vm', vm_name]
            if box.get('cpus'):
                args += ['-c', str(box['cpus'])]
            if box.get('mem'):
                args += ['-m', str(box['mem'])]
            if not self._run_govc(args):
                return False

        if not self._connect_network_devices(vm_name):
            return False

        if not self._run_govc(['vm.power', '-on', vm_name]):
            return False
        if not self._connect_network_devices(vm_name):
            return False
        return self._bootstrap_guest(vm_name, box)

    def install(self):
        boxes = self._get_boxes()
        if not boxes:
            Log.error('No VM to deploy')
            return False
        if not self.ovftool_target:
            Log.warning(
                'vsphere_ovftool_target is empty; this only works when vsphere_server '
                'is a direct ESXi host. For vCenter, set the datacenter/host/cluster path.'
            )
        for box in boxes:
            Log.info(f'Deploy {box["name"]} from {box["box"]}')
            if not self._deploy_box(box):
                return False
        return True

    def destroy(self):
        result = True
        for box in self._get_boxes():
            vm_name = self._vm_name(box)
            self._run_govc(['vm.power', '-off', vm_name])
            result = self._run_govc(['vm.destroy', vm_name]) and result
        return result

    def start(self):
        result = True
        for box in self._get_boxes():
            result = self._run_govc(['vm.power', '-on', self._vm_name(box)]) and result
        return result

    def stop(self):
        result = True
        for box in self._get_boxes():
            result = self._run_govc(['vm.power', '-off', self._vm_name(box)]) and result
        return result

    def status(self):
        result = True
        for box in self._get_boxes():
            result = self._run_govc(['vm.info', self._vm_name(box)]) and result
        return result

    def start_vm(self, vm_name):
        return self._run_govc(['vm.power', '-on', vm_name])

    def stop_vm(self, vm_name):
        return self._run_govc(['vm.power', '-off', vm_name])

    def destroy_vm(self, vm_name):
        self.stop_vm(vm_name)
        return self._run_govc(['vm.destroy', vm_name])

    def get_jumpbox_ip(self, ip_range=''):
        return ip_range + '.3'
