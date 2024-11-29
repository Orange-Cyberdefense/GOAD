# 🏟️ Ludus

!!! success "Thanks!"
    Huge shootout to @badsectorlabs for Ludus and Erik for his support and tests during the ludus provider creation

<div align="center">
  <img alt="ludus" width="200" height="150" src="./../img/icon_ludus.png">
  <img alt="icon_ansible" width="145"  height="150" src="./../img/icon_ansible.png">
</div>

!!! warning "Install on ludus server only"
    To add GOAD on Ludus please use goad directly on the server.
    By now goad can work only directly on the server and not from a workstation client.

- Install Ludus : [https://docs.ludus.cloud/docs/quick-start/install-ludus/](https://docs.ludus.cloud/docs/quick-start/install-ludus/)

- Be sure to create an **admin** user and keep his api key
- Once your installation is complete on ludus server (debian 12) and your user is created do :

```bash
git clone https://github.com/Orange-Cyberdefense/GOAD.git
cd GOAD
sudo apt install python3.11-venv        # because by default ludus use debian 12 with python3.11
export LUDUS_API_KEY='myapikey'         # put your api key here
./goad.sh -p ludus
GOAD/ludus/local > check
GOAD/ludus/local > set_lab XXX # GOAD/GOAD-Light/NHA/SCCM
GOAD/ludus/local > install
```

And goad launch the installation ;)

## Goad configuration

- If you don't want to do the export LUDUS_API_KEY before using goad you can also add the api_key in the goad.ini configuration file
- The goad configuration file as some options for ludus:

```
# ~/.goad/goad.ini
...
[ludus]
ludus_api_key = changeme
use_impersonation = yes
```

- change the api_key with the one of your admin user

## Install

```bash
./goad.sh -p ludus
GOAD/ludus/local > set_lab XXX # GOAD/GOAD-Light/NHA/SCCM
GOAD/ludus/local > install
```

- The installation will create a new simple_user to generate the pool we will call him "lab_user" the id of this user will be `lab_name<6alphanumeric_digit>`
- Next this "lab_user" will be impersonate to launch all the ludus deployment command
- At the end the "lab_user" will share access to our user
- This way we can manage multiple lab instance with goad on the same ludus server.

!!! info
    On ludus the config ip_range is not used and is ignored. The ips will be setup automatically during the lab installation