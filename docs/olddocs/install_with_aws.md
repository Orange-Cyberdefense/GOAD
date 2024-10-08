# AWS setup

The architecture is the same than the Azure deployment.

![Architecture](img/azure_architecture.png)

> **Warning**
> LLMNR, NBTNS and other poisoning network attacks will not work in AWS environment.
> Only network coerce attacks will work.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/?nc1=h_ls)

## AWS configuration

You need to configre AWS cli. Use a key with enough privileges on the tenant.

```bash
aws configure
```

## Configuration

Before installing, it is **mandatory** to modify the `ad/GOAD/providers/aws/terraform/values.tfvars` file in order to match your needs, specifically:

- zone: where you want to deploy GOAD
- whitelist\_cidr: your own IP address range (usually /32). This will be used as a whitelist to allow access to the jumpbox.

Other configurable variables are listed in the `variable.tf` file.

## Automatic installation

```bash
# Check prerequisites
./goad.sh -t check -l GOAD -p aws
# Install
./goad.sh -t install -l GOAD -p aws
```

![aws check](./img/aws_check.png)

## Lab access

The SSH key necessary to connect the jumpbox is generated in `ad/GOAD/providers/aws/ssh_keys`.

```
ssh goad@$PUBLIC_IP -i ubuntu-jumpbox.pem
```

The credentials to access the Windows machines can be found in the usual inventory file. As a backup, an AWS key pair is provided, allows retrieving the administrator password in case the initial provisioning script fails. The local administrator for all servers is **goadmin**.

## Manual installation

### Build the infrastructure with Terraform.

1. Initialize Terraform

```bash
cd terraform
terraform init
```

2. Generate the terraform plan with the password

```bash
cd ad/GOAD/providers/aws/terraform
terraform plan -out tfplan -var-file="values.tfvars"
```

> Note: The plan is useful to check if the terraform configuration is correct

3. Apply the terraform plan

```bash
terraform apply tfplan -var-file="values.tfvars"
```

> Note: The terraform apply command will take a few minutes to complete

At the end of the terraform apply, the output will show the public ip of the Ubuntu VM. This VM will be used to run the ansible playbook to provision the Windows VM.

### Windows VM provisionning with Ansible
0. Rsync source on Ubuntu VM

```bash
cd ../../../../../ # to the repository root folder
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rsync -a --exclude-from='.gitignore' -e "ssh -i $CURRENT_DIR/ad/GOAD/providers/aws/ssh_keys/ubuntu-jumpbox.pem" "$CURRENT_DIR/" goad@$public_ip:~/GOAD/
```

1. Run the setup.sh script to install Ansible and download GOAD on the Ubuntu VM

```bash
ssh -i ad/GOAD/providers/aws/ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu-jumpbox-ip> 'bash -s' < scripts/setup_aws.sh
```

> Note: To get the public ip of the Ubuntu VM, you can run `terraform output` in the terraform directory

2. Connect to the Ubuntu VM

```bash
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu-jumpbox-ip>
```

3. Run the playbook to provision the Windows VM

```bash
cd ansible
export ANSIBLE_COMMAND="ansible-playbook -i ../ad/GOAD/data/inventory -i ../ad/GOAD/providers/aws/inventory"
../scripts/provisionning.sh
```

- Details on the provisioning process are here : [provisioning.md](./provisioning.md)

## Tips

- To connect to the Windows VM, you can use proxychains and xfreerdp through the Ubuntu VM

```bash
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu_public_ip> -D 1080
proxychains xfreerdp /u:goadmin /p:<password> /v:<windows_private_ip> +clipboard /dynamic-resolution /cert-ignore
```

- Good to know: you can also configure a SSH tunnel directly in remmina! **Be careful**: you should have already accepted the public key of the jumpbox in order to connect using remmina, through a regular ssh connection.
