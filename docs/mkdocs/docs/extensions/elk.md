# elk

🚧 TODO

## elk

- **elk** a kibana is configured on http://192.168.56.50:5601 to follow the lab events
- infos : log encyclopedia : https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/
- the elk is not installed by default due to resources reasons. 

- prerequistes: 
- you need `sshpass` for the elk installation
```bash
sudo apt install sshpass
```

- Chocolatey is needed to use elk. To install it run:
```bash
cd ansible-galaxy
ansible-galaxy collection install chocolatey.chocolatey 
```

