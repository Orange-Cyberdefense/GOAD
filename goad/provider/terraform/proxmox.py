from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *
from urllib.parse import urlparse
from goad.log import Log

from proxmoxer import ProxmoxAPI
import getpass
from rich.table import Table
from rich import print


class ProxmoxProvider(TerraformProvider):
    provider_name = PROXMOX
    default_provisioner = PROVISIONING_LOCAL
    allowed_provisioners =  [PROVISIONING_LOCAL, PROVISIONING_RUNNER]

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        self.pm_api_url = config.get_value('proxmox', 'pm_api_url')
        self.pm_user = config.get_value('proxmox', 'pm_user')
        self.pm_node = config.get_value('proxmox', 'pm_node')
        self.pm_pool = config.get_value('proxmox', 'pm_pool')
        self.pm_password = config.get_value('proxmox', 'pm_pass', None)

    def _get_proxmox(self):
        if self.pm_password is None:
            pm_password = getpass.getpass(f"Enter {self.pm_user} password : ")
        else:
            pm_password = self.pm_password
        parsed_url = urlparse(self.pm_api_url)
        proxmox = ProxmoxAPI(parsed_url.hostname, user=self.pm_user, password=pm_password, verify_ssl=False)
        try:
            proxmox.nodes.get()  # Fetches all nodes to verify connection
            self.pm_password = pm_password
            Log.success('authentication successful')
            return proxmox
        except Exception as e:
            Log.error(f'Authentication failed')
        return None

    def check(self):
        checks = [
            self.command.check_terraform(),
            self.command.check_ansible()
        ]
        return all(checks)

    @staticmethod
    def _color_vm_state(state):
        if state == "running":
            return f'[green]{state}[/green]'
        elif state == "stopped":
            return f'[red]{state}[/red]'
        return f'[yellow]{state}[/yellow]'

    def status(self):
        proxmox = self._get_proxmox()
        if proxmox is not None:
            pool_members = proxmox.pools(self.pm_pool).get()
            running_vms_containers = []

            table = Table()
            table.add_column('VM Id')
            table.add_column('Name')
            table.add_column('hostname')
            table.add_column('Status')
            table.add_column('Type')
            table.add_column('IP')

            for member in pool_members['members']:
                # Check for QEMU VMs (type 'qemu') and LXC containers (type 'lxc')
                if member['type'] in ['qemu', 'lxc']:
                    # Fetch the status of the VM/container to see if it's running
                    node = member['node']
                    vmid = member['vmid']
                    ip_address = "No IP Found"

                    if member['type'] == 'qemu':
                        vm_status = proxmox.nodes(node).qemu(vmid).status.current.get()
                        vm_config = proxmox.nodes(node).qemu(vmid).config.get()  # To get the name
                    else:
                        vm_status = proxmox.nodes(node).lxc(vmid).status.current.get()
                        vm_config = proxmox.nodes(node).lxc(vmid).config.get()  # To get the name

                    vm_name = vm_config.get('name', f"VMID-{vmid}")

                    vm_hostname = ""
                    # Proceed if the VM or container is running
                    if vm_status['status'] == 'running':
                        ip_address = "unreachable"

                        # Get IP for QEMU VMs by querying the network interface
                        if member['type'] == 'qemu':
                            try:
                                hostname = proxmox.nodes(node).qemu(vmid).agent('get-host-name').get()
                                vm_hostname = hostname['result'].get('host-name')
                                net_info = proxmox.nodes(node).qemu(vmid).agent('network-get-interfaces').get()
                                for interface in net_info['result']:
                                    for ip in interface.get('ip-addresses', []):
                                        # Only interested in non-loopback IPs (ignoring 127.x.x.x)
                                        if not ip['ip-address'].startswith('127') and not ip['ip-address'].startswith('::1') and not ip['ip-address'].startswith('fe80'):
                                            if ip_address == 'unreachable':
                                                ip_address = ip['ip-address']
                                            else:
                                                ip_address += ', ' + ip['ip-address']
                            except Exception as e:
                                Log.error(f"Error fetching IP for QEMU VM {vmid}: {e}")

                        # Get IP for LXC containers by querying the network status
                        elif member['type'] == 'lxc':
                            vm_hostname = vm_name
                            try:
                                for key, value in vm_config.items():
                                    if key.startswith('net'):
                                        ip_address = value.get('ip', ip_address)
                            except Exception as e:
                                Log.error(f"Error fetching IP for LXC {vmid}: {e}")

                    table.add_row(str(vmid), vm_name, vm_hostname, self._color_vm_state(vm_status['status']), member['type'], ip_address)
            print(table)

    def start(self):
        proxmox = self._get_proxmox()
        if proxmox is not None:
            try:
                pool_members = proxmox.pools(self.pm_pool).get()
                for member in pool_members['members']:
                    node = member['node']
                    vmid = member['vmid']
                    vm_type = member['type']
                    # Start QEMU VM
                    if vm_type == 'qemu':
                        try:
                            Log.info(f"Starting QEMU VM {vmid} on node {node}...")
                            proxmox.nodes(node).qemu(vmid).status.start.post()
                            Log.success(f"QEMU VM {vmid} started successfully.")
                        except Exception as e:
                            Log.error(f"Error starting QEMU VM {vmid}: {e}")
                    # Start LXC container
                    elif vm_type == 'lxc':
                        try:
                            Log.info(f"Starting LXC container {vmid} on node {node}...")
                            proxmox.nodes(node).lxc(vmid).status.start.post()
                            Log.success(f"LXC container {vmid} started successfully.")
                        except Exception as e:
                            Log.error(f"Error starting LXC container {vmid}: {e}")
            except Exception as e:
                print(f"Error fetching pool details or starting VMs/containers: {e}")

    def stop(self):
        proxmox = self._get_proxmox()
        if proxmox is not None:
            try:
                pool_members = proxmox.pools(self.pm_pool).get()
                for member in pool_members['members']:
                    node = member['node']
                    vmid = member['vmid']
                    vm_type = member['type']
                    # Start QEMU VM
                    if vm_type == 'qemu':
                        try:
                            Log.info(f"Stopping QEMU VM {vmid} on node {node}...")
                            proxmox.nodes(node).qemu(vmid).status.stop.post()
                            Log.success(f"QEMU VM {vmid} stopped successfully.")
                        except Exception as e:
                            Log.error(f"Error starting QEMU VM {vmid}: {e}")
                    # Start LXC container
                    elif vm_type == 'lxc':
                        try:
                            Log.info(f"Stopping LXC container {vmid} on node {node}...")
                            proxmox.nodes(node).lxc(vmid).status.stop.post()
                            Log.success(f"LXC container {vmid} stopped successfully.")
                        except Exception as e:
                            Log.error(f"Error starting LXC container {vmid}: {e}")
            except Exception as e:
                Log.error(f"Error fetching pool details or starting VMs/containers: {e}")

    def start_vm(self, vmid):
        proxmox = self._get_proxmox()
        if proxmox is not None:
            # Start the VM
            try:
                Log.info(f"Starting VM with VMID {vmid} on node {self.pm_node}...")
                proxmox.nodes(self.pm_node).qemu(vmid).status.start.post()
                Log.success(f"VM {vmid} started successfully.")
            except Exception as e:
                Log.error(f"Error starting VM {vmid}: {e}")

    def stop_vm(self, vmid):
        proxmox = self._get_proxmox()
        if proxmox is not None:
            # Start the VM
            try:
                Log.info(f"Stopping VM with VMID {vmid} on node {self.pm_node}...")
                proxmox.nodes(self.pm_node).qemu(vmid).status.stop.post()
                Log.success(f"VM {vmid} stopped successfully.")
            except Exception as e:
                Log.error(f"Error stopping VM {vmid}: {e}")

    def destroy_vm(self, vm_name):
        pass
