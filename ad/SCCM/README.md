# SCCM lab

![SCCM overview](../../docs/img/SCCMLAB_overview.png)

## Servers
4 virtual machines with Windows Server 2019

- **DC** :  Domain Controler 
- **MECM** : mecm primary site serer
- **MSSQL** : mecm sql server
- **CLIENT** : mecm client computer

All vms got defender activated

## Prerequisites
- The prerequisites for the lab are the same as GOAD lab (virtualbox/vmware, python, ansible,...)
- The lab take 16GB for the vagrant image + 100GB for the 4 vms
- The installation take environ 2,5 hours (with fiber connection)
- The lab download multiple files during the install (windows iso, mecm installation package, mssql installation package, ...), be sure to have a good internet connection.

## virtualization providers
- By now only vmware and virtualbox are available as provider. 