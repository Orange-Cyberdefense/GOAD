from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *
from goad.log import Log
# AWS
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
# rich
from rich.table import Table
from rich import print


class AwsProvider(TerraformProvider):
    provider_name = AWS
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        self.jumpbox_setup_script = 'setup_aws.sh'
        self.tag = lab_name
        self.aws_region = config.get_value('aws', 'aws_region', 'eu-west-3')
        self.aws_zone = config.get_value('aws', 'aws_zone', 'eu-west-3c')
        self.profile_name = 'goad'

    def set_tag(self, tag):
        # tag should be <instance_id>-<LAB>
        self.tag = tag

    @staticmethod
    def _color_vm_state(state):
        if state == "running":
            return f'[green]{state}[/green]'
        elif state == "stopped":
            return f'[red]{state}[/red]'
        return f'[yellow]{state}[/yellow]'

    def check(self):
        # check terraform bin
        check = super().check()
        check_aws = self.command.check_aws()
        check = check and check_aws

        try:
            session = boto3.Session(profile_name=self.profile_name)
            # Create an STS client using the session
            sts = session.client('sts')
            # Get the identity of the caller
            response = sts.get_caller_identity()
            # Print the user information
            Log.success(f"Connected to AWS using profile '{self.profile_name}'")
            Log.info("User Information:")
            Log.info(f"  Account: {response['Account']}")
            Log.info(f"  User ARN: {response['Arn']}")
            Log.info(f"  User ID: {response['UserId']}")
            check = check and True
        except NoCredentialsError:
            Log.error("Credentials not available.")
            check = False
        except PartialCredentialsError:
            Log.error("Incomplete credentials provided.")
            check = False
        except Exception as e:
            Log.error(f"An error occurred: {e}")
            check = False
        return check

    def status(self):
        session = boto3.Session(profile_name=self.profile_name)
        ec2_client = session.client('ec2', self.aws_region)
        aws_ec2 = ec2_client.describe_instances()
        table = Table()
        table.add_column('VM Id')
        table.add_column('Name')
        table.add_column('Location')
        table.add_column('PowerState')
        table.add_column('PublicIP')
        table.add_column('PrivateIP')
        for reservation in aws_ec2["Reservations"]:
            for vm_instance in reservation["Instances"]:
                vm_id = vm_instance["InstanceId"]
                vm_name = ''
                vm_location = self.aws_zone
                vm_state = self._color_vm_state(vm_instance["State"]["Name"])
                vm_public_ip = ''
                vm_private_ip = ''
                vm_lab = ''
                if "Tags" in vm_instance:
                    for tag in vm_instance["Tags"]:
                        if tag['Key'] == "Name":
                            vm_name = tag["Value"]
                        if tag['Key'] == "Lab":
                            vm_lab = tag["Value"]
                if "PublicIpAddress" in vm_instance:
                    vm_public_ip = vm_instance["PublicIpAddress"]
                if "PrivateIpAddress" in vm_instance:
                    vm_private_ip = vm_instance["PrivateIpAddress"]
                if vm_lab != '' and vm_lab == self.tag:
                    table.add_row(vm_id, vm_name, vm_location, vm_state, vm_public_ip, vm_private_ip)

        print(table)

    def _get_vm_instance_id_list(self, ec2_client):
        aws_ec2 = ec2_client.describe_instances()
        instances_ids = []
        for reservation in aws_ec2["Reservations"]:
            for vm_instance in reservation["Instances"]:
                if "Tags" in vm_instance:
                    for tag in vm_instance["Tags"]:
                        if tag['Key'] == "Lab":
                            vm_lab = tag["Value"]
                            if vm_lab != '' and vm_lab == self.tag:
                                instances_ids.append(vm_instance["InstanceId"])
        return instances_ids

    def start(self):
        session = boto3.Session(profile_name=self.profile_name)
        ec2_client = session.client('ec2', self.aws_region)
        instances_ids = self._get_vm_instance_id_list(ec2_client)
        ec2_client.start_instances(InstanceIds=instances_ids)
        Log.info('lab start in progres')

    def stop(self):
        session = boto3.Session(profile_name=self.profile_name)
        ec2_client = session.client('ec2', self.aws_region)
        instances_ids = self._get_vm_instance_id_list(ec2_client)
        ec2_client.stop_instances(InstanceIds=instances_ids)
        Log.info('lab stop in progres')

    def start_vm(self, vm_id):
        session = boto3.Session(profile_name=self.profile_name)
        ec2_client = session.client('ec2', self.aws_region)
        instances_ids = self._get_vm_instance_id_list(ec2_client)
        found = False
        for instances_id in instances_ids:
            if instances_id == vm_id:
                found = True
                ec2_client.start_instances(InstanceIds=[instances_id])

        if found:
            Log.info(f'lab vm {vm_id} start in progres')
        else:
            Log.error(f'vm id {vm_id} not found, be sure to use the instance_id and not the name for aws')
        return found

    def stop_vm(self, vm_id):
        session = boto3.Session(profile_name=self.profile_name)
        ec2_client = session.client('ec2', self.aws_region)
        instances_ids = self._get_vm_instance_id_list(ec2_client)
        found = False
        for instances_id in instances_ids:
            if instances_id == vm_id:
                found = True
                ec2_client.stop_instances(InstanceIds=[instances_id])
        if found:
            Log.info(f'lab vm {vm_id} stop in progres')
        else:
            Log.error(f'vm id {vm_id} not found, be sure to use the instance_id and not the name for aws')
        return found

    def destroy_vm(self, vm_id):
        session = boto3.Session(profile_name=self.profile_name)
        ec2_client = session.client('ec2', self.aws_region)
        instances_ids = self._get_vm_instance_id_list(ec2_client)
        found = False
        for instances_id in instances_ids:
            if instances_id == vm_id:
                found = True
                ec2_client.terminate_instances(InstanceIds=[instances_id])
        if found:
            Log.info(f'lab vm {vm_id} terminate in progres')
        else:
            Log.error(f'vm id {vm_id} not found, be sure to use the instance_id and not the name for aws')
        return found

    def get_jumpbox_ip(self, ip_range=''):
        jumpbox_ip = self.command.run_terraform_output(['ubuntu-jumpbox-ip'], self.path)
        if jumpbox_ip is None:
            Log.error('Jump box ip not found')
            return None
        if not Utils.is_valid_ipv4(jumpbox_ip):
            Log.error('Invalid IP')
            return None
        return jumpbox_ip
