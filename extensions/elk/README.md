Name: elk
Description: Add an ELK to the current lab
Labs: *
Providers:
  - vmware
  - virtualbox
  - azure
  - aws
  - proxmox
install:
  - machine: ELK
  - agent on domain computer machines