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

> Note: The terraform apply command will take a few minutes to complete

At the end of the terraform apply, the output will show the public ip of the Ubuntu VM. This VM will be used to run the ansible playbook to provision the Windows VM.

## Windows VM provisionning with Ansible

1. Run the setup.sh script to install Ansible and download GOAD on the Ubuntu VM

```bash
cd ..
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu-jumpbox-ip> 'bash -s' < setup.sh
```

> Note: To get the public ip of the Ubuntu VM, you can run `terraform output` in the terraform directory

2. Connect to the Ubuntu VM

```bash
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu-jumpbox-ip>
```

3. Replace the `ansible_password` variable in the inventory file with the generated password

```bash
nano GOAD/ad/azure-sevenkingdoms.local/inventory
```

4. Run the playbook to provision the Windows VM

```bash
cd GOAD/ansible
source .venv/bin/activate
ansible-playbook -i ../ad/azure-sevenkingdoms.local/inventory main.yml
```

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