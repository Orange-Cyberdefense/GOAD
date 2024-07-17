#!/bin/bash

sudo apt-get update
sudo apt-get install --no-install-recommends -y git python3-venv python3-pip

python3 -m venv .venv
source .venv/bin/activate

# Install ansible and pywinrm
pip3 install ansible-core==2.17.0
pip3 install pywinrm
ansible-galaxy install -r /home/goad/GOAD/ansible/requirements.yml

sudo su 

# Install wireguard
apt-get update
apt-get install -y wireguard iptables resolvconf qrencode
chmod 600 -R /etc/wireguard/

##  Configure server
IMDS_TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
SERVER_PUB_IP=$(curl -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
SERVER_PUB_NIC="$(ip -4 route | grep default | grep -oP 'dev \K\w*')"
SERVER_WG_NIC=wg0
SERVER_WG_IPV4=10.0.0.1/24
SERVER_PORT=443
SERVER_PRIV_KEY=$(wg genkey)
SERVER_PUB_KEY=$(echo "${SERVER_PRIV_KEY}" | wg pubkey)
ALLOWED_IPS=192.168.56.0/24

echo  "SERVER_PUB_IP=${SERVER_PUB_IP}
SERVER_PUB_NIC=${SERVER_PUB_NIC}
SERVER_WG_NIC=${SERVER_WG_NIC}
SERVER_WG_IPV4=${SERVER_WG_IPV4}
SERVER_PORT=${SERVER_PORT}
SERVER_PRIV_KEY=${SERVER_PRIV_KEY}
SERVER_PUB_KEY=${SERVER_PUB_KEY}
ALLOWED_IPS=${ALLOWED_IPS}" >/etc/wireguard/params

echo "[Interface]
Address = $SERVER_WG_IPV4
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIV_KEY
PostUp = iptables -I INPUT -p udp --dport ${SERVER_PORT} -j ACCEPT
PostUp = iptables -I FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT
PostUp = iptables -I FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
PostDown = iptables -D INPUT -p udp --dport ${SERVER_PORT} -j ACCEPT
PostDown = iptables -D FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT
PostDown = iptables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE" > "/etc/wireguard/${SERVER_WG_NIC}.conf"

echo "net.ipv4.ip_forward = 1" >/etc/sysctl.d/wg.conf

sysctl --system
systemctl start "wg-quick@${SERVER_WG_NIC}"
systemctl enable "wg-quick@${SERVER_WG_NIC}"

## Configure client
ENDPOINT="${SERVER_PUB_IP}:${SERVER_PORT}"
#CLIENT_IP=$(grep "Accepted" /var/log/auth.log | grep "goad" | tail -n 1 | grep -oP "from \K[^ ]*")
CLIENT_WG_IPV4="10.0.0.2/32"
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "${CLIENT_PRIV_KEY}" | wg pubkey)
CLIENT_PRE_SHARED_KEY=$(wg genpsk)

echo "[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_WG_IPV4}

[Peer]
PublicKey = ${SERVER_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
Endpoint = ${ENDPOINT}
AllowedIPs = ${ALLOWED_IPS}" >"/home/goad/wg-pentest.conf"

echo -e "\n[Peer]
PublicKey = ${CLIENT_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
AllowedIPs = ${CLIENT_WG_IPV4}" >> "/etc/wireguard/${SERVER_WG_NIC}.conf"

wg syncconf "${SERVER_WG_NIC}" <(wg-quick strip "${SERVER_WG_NIC}")
