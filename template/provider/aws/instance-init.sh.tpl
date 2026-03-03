#!/bin/bash
usermod -l "${username}" ubuntu  
usermod -d "/home/${username}" -m ${username}
sed -i "s/ubuntu/${username}/" /etc/sudoers.d/90-cloud-init-users
echo "${username}":"${password}" | chpasswd

# Enable password authentication
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/*.conf
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/*.conf
systemctl restart ssh