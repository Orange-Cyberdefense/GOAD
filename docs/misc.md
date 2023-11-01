## MISC commands

### Force replication (no more used)

- On dragonstone play as domain admin user :
```
repadmin /replicate kingslanding.sevenkingdoms.local dragonstone.sevenkingdoms.local dc=sevenkingdoms,dc=local /full
```

### vagrant useful commands (vm management)

- start all lab vms :
```
vagrant up
```

- start only one vm :
```
vagrant up <vmname>
```

- stop all the lab vm :
```
vagrant halt
```

- drop all the lab vm (because you want to recreate all) (carrefull : this will erase all your lab instance)
```
vagrant destroy
```

- snapshot the lab (https://www.vagrantup.com/docs/cli/snapshot)
```
vagrant snapshot push
```

- restore the lab snapshot (this could break servers relationship, reset servers passwords with fix_trust.yml playbook)
```
vagrant snapshot pop
```

### ansible commands (provisioning management)
#### Play only an ansible part
- only play shares of member_server.yml :
```
ansible-playbook member_server.yml --tags "data,shares"
```

#### Play only on some server
```
ansible-playbook -l dc2 domain_controller.yml
```

#### Add some vulns
```
ansible-playbook vulnerabilities.yml
```

