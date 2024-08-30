# extension template

## structure
```
ansible/          (required)
    inventory      (required)
    install.yml    (required)
    uninstal.yml   (required)
    ansible.cfg    (optional : to load main ansible roles)
    data.yml       (optional : to include lab data and if needed include other datas)
providers/        (optional)
    aws/
        ext_name.tf
    azure/
        ext_name.tf
    proxmox/
        ext_name.tf
    vmware/
        ext_name.rb
    virtualbox/
        ext_name.rb
```
