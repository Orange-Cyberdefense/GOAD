Name: elk
Description: Add an ELK to the current lab
Labs:
  - GOAD
  - GOAD-Light
  - SCCM
  - NHA
  - MINILAB
Providers:
  - vmware
  - virtualbox
  - azure
  - aws
  - proxmox
install:
  - machine: ELK
  - playbooks:
      -