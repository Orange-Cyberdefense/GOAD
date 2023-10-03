#!/bin/bash

function print_info {
    echo -e "\n\n"
    echo "Ubuntu jumpbox IP: $public_ip"
    echo "goadmin password: $password"

    echo "You can now connect to the jumpbox using the following command:"
    echo "ssh -i ssh_keys/ubuntu-jumpbox.pem goad@$public_ip"
    echo -e "\n\n"
}

# Generate a random password
echo "Generating password..."
# Check if MacOS
OS=`uname`
if [ "$OS" = 'Darwin' ]; then
    export LC_CTYPE=C
fi
password=$(cat /dev/urandom | $LC_CTYPE tr -dc A-Za-z0-9 | head -c 30)

# Initialize Terraform
echo "Initializing Terraform..."
cd terraform
terraform init

# Apply Terraform
echo "Applying Terraform..."
terraform apply -var "password=$password"

# Get the public IP address of the VM
echo "Getting jumpbox IP address..."
public_ip=$(terraform output -raw ubuntu-jumpbox-ip)

print_info

# Run setup script on the jumpbox
echo "Running setup script on jumpbox..."
cd ..
ssh -o "StrictHostKeyChecking no" -i ssh_keys/ubuntu-jumpbox.pem goad@$public_ip 'bash -s' <scripts/setup.sh

# Replace the password in the Ansible inventory file
echo "Replacing password in Ansible inventory file..."
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@$public_ip "sed -i 's/YourSuperSecretPassword/$password/g' GOAD/ad/azure-sevenkingdoms.local/inventory"

# Run the Ansible playbook
echo "Running Ansible playbook..."
ssh -i ssh_keys/ubuntu-jumpbox.pem goad@$public_ip 'bash -s' <scripts/provisionning.sh

print_info
