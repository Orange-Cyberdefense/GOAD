# Azure setup

## Build the infrastructure with Terraform.

1. Initialize Terraform

```bash
cd terraform
terraform init
```

2. Generate a password for the windows vm

```bash
cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 30
```

3. Put the generated password in the inventory file

```bash
...
ansible_password=<password>
...
```

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

At the end of the terraform apply, the output will show the public ip of the ubuntu vm. This vm will be used to run the ansible playbook to provision the windows vm. To connect to the ubuntu vm, use the following command:

```bash
cd ..
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@<ubuntu_public_ip>
```