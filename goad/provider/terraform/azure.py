import json
from goad.log import Log
from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *
from rich.table import Table
from goad.exceptions import *
from rich import print
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import ClientAuthenticationError
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient


class AzureProvider(TerraformProvider):
    provider_name = AZURE
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]

    def __init__(self, lab_name):
        super().__init__(lab_name)
        self.resource_group = lab_name
        self.jumpbox_setup_script = 'setup_azure.sh'

    def set_resource_group(self, resource_group):
        self.resource_group = resource_group

    def _get_subscription_id(self):
        credential = DefaultAzureCredential()
        if credential is not None:
            # find default subscription with subprocess (python sdk doesn't show it)
            az_accounts = self.command.get_azure_account_output()
            if az_accounts is not None:
                subscriptions = json.loads(az_accounts)
                for subscription in subscriptions:
                    if subscription.get("isDefault"):
                        return subscription.get("id")
        return None

    def check(self):
        # check terraform bin
        check = super().check()
        check_az = self.command.check_azure()
        check = check and check_az
        # check azure login
        try:
            credential = DefaultAzureCredential()
            if credential is not None:
                Log.success(f'Azure authentication ok')

                # find default subscription with subprocess (python sdk doesn't show it)
                az_accounts = self.command.get_azure_account_output()
                if az_accounts is not None:
                    subscriptions = json.loads(az_accounts)
                    for subscription in subscriptions:
                        if subscription.get("isDefault"):
                            Log.info(f'Subscription name : {subscription.get("name")}')
                            Log.info(f'Subscription id : {subscription.get("id")}')
                            Log.info(f'Tenant ID : {subscription.get("tenantId")}')
                            Log.info(f'State : {subscription.get("state")}')
                            Log.info('If you want to change subscription use: az account set --subscription "<subscription id>" ')
                            check = check and True
        except ClientAuthenticationError as error:
            Log.error(f'Azure authentication error : {error.message}')
            Log.info('Please login before launching the app with "az login"')
            check = False
        except Exception as error:
            Log.error(f'Exception during the azure check : {error.message}')
            check = False
        return check

    def _auth(self):
        # Initialize DefaultAzureCredential
        credential = DefaultAzureCredential()
        if credential is None:
            raise AuthenticationFailed('Azure authentication ko')
        subscription_id = self._get_subscription_id()
        if subscription_id is None:
            raise AuthenticationFailed('Subscription ID not found')
        return credential, subscription_id

    def status(self):
        try:
            credential, subscription_id = self._auth()
        except AuthenticationFailed as e:
            Log.error(e)
            return False

        try:
            # get VMS status
            # Initialize the ComputeManagementClient with the credential
            compute_client = ComputeManagementClient(credential, subscription_id)
            network_client = NetworkManagementClient(credential, subscription_id)

            # List all VMs in the specified resource group
            vms = compute_client.virtual_machines.list(self.resource_group)
            Log.info(f"Azure VMs for resource {self.resource_group}")
            table = Table()
            table.add_column('VM Id')
            table.add_column('Name')
            table.add_column('Location')
            table.add_column('PowerState')
            table.add_column('PublicIP')
            table.add_column('PrivateIP')

            # Fetch details of each VM
            vm_details = []
            for vm in vms:
                # IPs
                vm_public_ips = []
                vm_private_ips = []
                for interface in vm.network_profile.network_interfaces:
                    nic_name = " ".join(interface.id.split('/')[-1:])
                    nic_resource_group = "".join(interface.id.split('/')[4])
                    for ip in network_client.network_interfaces.get(nic_resource_group, nic_name).ip_configurations:
                        if ip.private_ip_address is not None:
                            vm_private_ips.append(ip.private_ip_address)
                        if ip.public_ip_address is not None:
                            public_ip_name = ip.public_ip_address.id.split('/')[-1]
                            # Get public IP address details
                            public_ip = network_client.public_ip_addresses.get(nic_resource_group, public_ip_name)
                            vm_public_ips.append(public_ip.ip_address)

                # powerstate
                instance_view = compute_client.virtual_machines.instance_view(self.resource_group, vm.name)

                power_state = next((status.code for status in instance_view.statuses if status.code.startswith('PowerState/')), 'Unknown')
                if power_state.startswith('PowerState/'):
                    power_state = power_state.split("PowerState/", 1)[1]

                if 'running' in power_state:
                    power_state = f'[green]{power_state}[/green]'
                elif 'Unknown' in power_state:
                    power_state = f'[yellow]{power_state}[/yellow]'
                else:
                    power_state = f'[red]{power_state}[/red]'
                # Append the VM details to the list
                table.add_row(vm.vm_id, vm.name, vm.location, power_state, ','.join(vm_public_ips), ','.join(vm_private_ips))
            print(table)
        except Exception as e:
            Log.error('Error retreiving running vms')
            return False

    def start(self):
        try:
            credential, subscription_id = self._auth()
        except AuthenticationFailed as e:
            Log.error(e)
            return False
        try:
            # Initialize the ComputeManagementClient with the credential
            compute_client = ComputeManagementClient(credential, subscription_id)
            Log.info('Start the lab  vms')
            # List all VMs in the specified resource group
            for vm in compute_client.virtual_machines.list(self.resource_group):
                async_vm_stop = compute_client.virtual_machines.begin_start(self.resource_group, vm.name)
                async_vm_stop.wait()
                Log.success(f'vm {vm.name} started')
            self.status()
        except Exception as e:
            Log.error('Error starting the vms')
            return False

    def stop(self):
        try:
            credential, subscription_id = self._auth()
        except AuthenticationFailed as e:
            Log.error(e)
            return False
        try:
            # Initialize the ComputeManagementClient with the credential
            compute_client = ComputeManagementClient(credential, subscription_id)
            Log.info('Stopping the lab vms')
            # List all VMs in the specified resource group
            for vm in compute_client.virtual_machines.list(self.resource_group):
                async_vm_stop = compute_client.virtual_machines.begin_deallocate(self.resource_group, vm.name)
                async_vm_stop.wait()
                Log.success(f'vm {vm.name} deallocate (no more billed)')
            self.status()
        except Exception as e:
            Log.error('Error stoping the lab vms')
            return False

    def start_vm(self, vm_name):
        try:
            credential, subscription_id = self._auth()
        except AuthenticationFailed as e:
            Log.error(e)
            return False
        try:
            # Initialize the ComputeManagementClient with the credential
            compute_client = ComputeManagementClient(credential, subscription_id)
            Log.info(f'Start vm {vm_name}')
            found = False
            # List all VMs in the specified resource group
            for vm in compute_client.virtual_machines.list(self.resource_group):
                if vm_name == vm.name:
                    found = True
                    async_vm_stop = compute_client.virtual_machines.begin_start(self.resource_group, vm.name)
                    async_vm_stop.wait()
                    Log.success(f'vm {vm.name} started')
        except Exception as e:
            Log.error(f'Error starting vm {vm_name}')
            return False
        if not found:
            Log.error('vm not found')
        return found

    def stop_vm(self, vm_name):
        try:
            credential, subscription_id = self._auth()
        except AuthenticationFailed as e:
            Log.error(e)
            return False
        try:
            # Initialize the ComputeManagementClient with the credential
            compute_client = ComputeManagementClient(credential, subscription_id)
            Log.info(f'Stopping vm {vm_name}')
            found = False
            # List all VMs in the specified resource group
            for vm in compute_client.virtual_machines.list(self.resource_group):
                if vm_name == vm.name:
                    found = True
                    async_vm_stop = compute_client.virtual_machines.begin_power_off(self.resource_group, vm.name)
                    async_vm_stop.wait()
                    Log.success(f'vm {vm.name} power off (still billed)')
        except Exception as e:
            Log.error(f'Error stopping vm {vm_name}')
            return False
        if not found:
            Log.error('vm not found')
        return found

    def destroy_vm(self, vm_name):
        try:
            credential, subscription_id = self._auth()
        except AuthenticationFailed as e:
            Log.error(e)
            return False
        try:
            # Initialize the ComputeManagementClient with the credential
            compute_client = ComputeManagementClient(credential, subscription_id)
            Log.info(f'Deleting vm {vm_name}')
            found = False
            # List all VMs in the specified resource group
            for vm in compute_client.virtual_machines.list(self.resource_group):
                if vm_name == vm.name:
                    found = True
                    async_vm_destroy = compute_client.virtual_machines.begin_delete(self.resource_group, vm.name)
                    async_vm_destroy.wait()
                    Log.success(f'vm {vm.name} deleted')
        except Exception as e:
            Log.error(f'Error deleting vm {vm_name}')
            return False
        if not found:
            Log.error('vm not found')
        return found

    def _get_az_jumpbox_ip(self):
        try:
            credential, subscription_id = self._auth()
        except AuthenticationFailed as e:
            Log.error(e)
            return None
        # get VMS status
        # Initialize the ComputeManagementClient with the credential
        try:
            compute_client = ComputeManagementClient(credential, subscription_id)
            network_client = NetworkManagementClient(credential, subscription_id)

            # List all VMs in the specified resource group
            vms = compute_client.virtual_machines.list(self.resource_group)
            # Fetch details of each VM
            vm_details = []
            for vm in vms:
                if 'ubuntu-jumpbox' in vm.name:
                    # IPs
                    vm_public_ips = []
                    for interface in vm.network_profile.network_interfaces:
                        nic_name = " ".join(interface.id.split('/')[-1:])
                        nic_resource_group = "".join(interface.id.split('/')[4])
                        for ip in network_client.network_interfaces.get(nic_resource_group, nic_name).ip_configurations:
                            if ip.public_ip_address is not None:
                                public_ip_name = ip.public_ip_address.id.split('/')[-1]
                                # Get public IP address details
                                public_ip = network_client.public_ip_addresses.get(nic_resource_group, public_ip_name)
                                return public_ip.ip_address
        except Exception as e:
            Log.error('Error retreiving jumpbox ip')
            return False
        return None

    def get_jumpbox_ip(self, ip_range=''):
        jumpbox_ip = self.command.run_terraform_output(['ubuntu-jumpbox-ip'], self.path)
        if jumpbox_ip is None:
            Log.error('Jump box ip not found')
            return None
        if not Utils.is_valid_ipv4(jumpbox_ip):
            Log.error('Invalid IP')
            return None
        return jumpbox_ip
