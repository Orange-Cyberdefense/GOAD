## Lab organization

- The lab configuration is located on the ad/ folder
- Each Ad folder correspond to a lab and contains the following files :

```
ad/
  labname/            # The lab name must be the same as the variable : domain_name from the data/inventory
    data/
      config.json     # The json file containing all the variables and configuration of the lab
      inventory       # The global lab inventory (provider independent) (this should no contains variables)
    files/            # This folder contains files you want to copy on your vms
    scripts/          # This folder contains ps1 scripts you want to play on your vm (Must be added in the "scripts" entries of your vms)
    providers/        # Your lab available provider
      vmware/
        inventory     # specific vmware inventory
        Vagrantfile   # specific vmware vagrantfile
      virtualbox/
        inventory     # specific virtualbox inventory
        Vagrantfile   # specific virtualbox vagrantfile
      proxmox/
        terraform/    # specific proxmox terraform recipe
        inventory     # specific proxmox inventory
      azure/
        terraform/    # specific azure terraform recipe
        inventory     # specific azure inventory
```
