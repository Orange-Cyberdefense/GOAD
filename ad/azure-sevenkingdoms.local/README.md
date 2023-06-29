# Azure setup

## Build the infrastructure with Terraform.

1. Initialize Terraform

```bash
cd terraform
terraform init
```

2. Generate a password for the Windows VM

```bash
cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 30
```

> Note: Keep the password, it will be used later

4. Generate the terraform plan with the password

```bash
terraform plan -out tfplan -var 'password=<password>'
```

> Note: The plan is useful to check if the terraform configuration is correct

5. Apply the terraform plan

```bash
terraform apply tfplan
```

> Note: The terraform apply will take a few minutes to complete

At the end of the terraform apply, the output will show the public ip of the Ubuntu VM. This VM will be used to run the ansible playbook to provision the Windows VM.

## Provision the Windows VM with Ansible

1. Run the setup.sh script to install Ansible and download GOAD on the Ubuntu VM

```bash
cd ..
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu_public_ip> 'bash -s' < setup.sh
```

2. Put the generated password in the inventory file

```bash
nano GOAD/ad/azure-sevenkingdoms.local/inventory
```