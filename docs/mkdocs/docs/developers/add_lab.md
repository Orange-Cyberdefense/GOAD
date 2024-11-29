# Add a new lab

🚧 TODO TO BE COMPLETED

- To create a new lab:
    - Create a new folder in `ad/` with the name of the lab
    - Create the following structure:
    ```
    ad/<lab_name>/
        data/
            config.json                 # json containing all the lab information
            inventory                   # global lab inventory file with the vm groups and the main variables
            inventory_disable_vagrant   # inventory to disable/enable vagrant
        files/
        providers/
            aws|azure|proxmox/          # terraform based providers
                inventory               # inventory specific to the provider
                linux.tf                # linux vms
                windows.tf              # windows vms
            ludus/                      # ludus provider
                inventory               # inventory specific to the provider
                config.yml              # ludus configuration file
            virtualbox|vmware/          # vagrant based provider
                inventory               # inventory specific to the provider
                Vagrantfile             # vms
        scripts/
    ```
