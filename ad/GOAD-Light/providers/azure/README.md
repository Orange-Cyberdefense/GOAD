# Azure setup

![Architecture](images/azure_architecture.png)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Azure configuration

You need to login to Azure with the CLI.

```bash
az login
```

## Automatic installation

```
./goad.sh -t install -l GOAD -p azure -m local
```

## Manual installation

### Build the infrastructure with Terraform.

1. Initialize Terraform

```bash
cd terraform
terraform init
```

2. Generate the terraform plan with the password

```bash
terraform plan -out tfplan
```

> Note: The plan is useful to check if the terraform configuration is correct

3. Apply the terraform plan

```bash
terraform apply tfplan
```

> Note: The terraform apply command will take a few minutes to complete

At the end of the terraform apply, the output will show the public ip of the Ubuntu VM. This VM will be used to run the ansible playbook to provision the Windows VM.

### Windows VM provisionning with Ansible
0. Rsync source on Ubuntu VM

```bash
cd ../../../../../ # to the repository root folder
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rsync -a --exclude-from='.gitignore' -e "ssh -i $CURRENT_DIR/ad/GOAD/providers/azure/ssh_keys/ubuntu-jumpbox.pem" "$CURRENT_DIR/" goad@$public_ip:~/GOAD/
```


1. Run the setup.sh script to install Ansible and download GOAD on the Ubuntu VM

```bash
ssh -i ad/GOAD/providers/azure/ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu-jumpbox-ip> 'bash -s' < scripts/setup_azure.sh
```

> Note: To get the public ip of the Ubuntu VM, you can run `terraform output` in the terraform directory

2. Connect to the Ubuntu VM

```bash
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu-jumpbox-ip>
```

3. Run the playbook to provision the Windows VM

```bash
cd ansible
export ANSIBLE_COMMAND="ansible-playbook -i ../ad/$lab/data/inventory -i ../ad/$lab/providers/$provider/inventory"
../scripts/provisionning.sh
```

> Note: LAPS feature have been disabled in the playbook because of error

## Tips

- To connect to the Windows VM, you can use proxychains and xfreerdp through the Ubuntu VM

```bash
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu_public_ip> -D 1080
proxychains xfreerdp /u:goadmin /p:<password> /v:<windows_private_ip> +clipboard /dynamic-resolution /cert-ignore
```

> Note: The password is the one generated at step 2 of the terraform section

- If the command `terraform destroy` fails, you can delete the resource group using the CLI

```bash
az group delete --name GOAD
```