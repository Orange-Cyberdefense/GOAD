# :simple-vmware: vSphere

The `vsphere` provider creates the lab VMs from the same Vagrant box definitions used by the VMware providers, but it does not run `vagrant up` and does not use the `vagrant-vmware-esxi` plugin.

The provider uses:

- `vagrant box add` to download/cache the VMware Vagrant boxes locally
- `ovftool` to import the VMX/OVF/OVA to vSphere over TCP/443
- `govc` to power, inspect, resize, and destroy VMs over TCP/443
- the existing GOAD Ansible inventories for lab provisioning

Ansible provisioning is unchanged. The host running GOAD still needs network access to the created guest IPs on WinRM/SSH.

## Prerequisites

- [Vagrant](https://developer.hashicorp.com/vagrant/install)
- [OVF Tool](https://developer.broadcom.com/tools/open-virtualization-format-ovf-tool/latest)
- [govc](https://github.com/vmware/govmomi/releases)
- vCenter or ESXi reachable on TCP/443
- VMware Tools installed and running in each Vagrant box
- Vagrant boxes with VMware provider artifacts, usually `vmware_desktop`
- Guest credentials for first boot bootstrap, default `vagrant` / `vagrant`

## Configuration

Add or update the vSphere settings in `~/.goad/goad.ini`. The file is created the first time `./goad.sh` is started.

```ini
[vsphere]
vsphere_server = vcenter.example.local
vsphere_user = administrator@vsphere.local
vsphere_password =
vsphere_allow_unverified_ssl = true
vsphere_datastore = datastore1
vsphere_network = GOAD-LAN
vsphere_ovftool_target =
vsphere_folder =
vsphere_resource_pool =
vsphere_disk_mode = thin
vsphere_box_provider = vmware_desktop
vsphere_bootstrap_guest_network = true
vsphere_guest_username = vagrant
vsphere_guest_password = vagrant
vsphere_ipv4_gateway =
vsphere_ipv4_prefix_length = 27
vsphere_dns_server =
vsphere_vm_name_prefix =
vsphere_overwrite = false
vsphere_ovftool_bin = ovftool
vsphere_govc_bin = govc
vsphere_network_adapter = e1000
```

VM names are prefixed with the GOAD instance id by default to avoid collisions. See the next section for commands to discover target, datastore, network, and folder values.

If `vsphere_password` is empty or still set to the generated placeholder value `password`, GOAD prompts for it when a vSphere command needs authentication. For non-interactive runs, set `VSPHERE_PASSWORD` or `GOVC_PASSWORD` in the environment instead.

## Discover vSphere values

The easiest way to collect the needed values is with `govc`. Use placeholder values below and avoid putting the password directly in shell history.

```bash
export GOVC_URL='vcenter.example.local'
export GOVC_USERNAME='administrator@vsphere.local'
read -rsp 'vSphere password: ' GOVC_PASSWORD; export GOVC_PASSWORD; echo
export GOVC_INSECURE=1

govc about
govc ls /
```

Use the datacenter name returned by `govc ls /`:

```bash
export GOVC_DATACENTER='Datacenter'

# clusters and hosts
govc ls "/${GOVC_DATACENTER}/host"

# datastores
govc ls "/${GOVC_DATACENTER}/datastore"
govc datastore.info

# networks and port groups
govc ls "/${GOVC_DATACENTER}/network"

# VM folders
govc ls "/${GOVC_DATACENTER}/vm"
```

Map the discovered values to `~/.goad/goad.ini` like this:

```ini
[vsphere]
vsphere_server = vcenter.example.local
vsphere_user = administrator@vsphere.local
vsphere_password =
vsphere_allow_unverified_ssl = true
vsphere_datastore = datastore1
vsphere_network = GOAD-LAN
vsphere_ovftool_target = Datacenter/host/Cluster
vsphere_folder = Labs/GOAD
vsphere_resource_pool =
```

Notes:

- `vsphere_server` is the vCenter or ESXi hostname only, without `https://`.
- `vsphere_datastore` is the datastore name shown by `govc ls "/${GOVC_DATACENTER}/datastore"` or `govc datastore.info`.
- `vsphere_network` is the destination vSphere network or port group name.
- `vsphere_network_adapter` is used only if the imported VM has no network adapter and GOAD needs to add one after import.
- `vsphere_ovftool_target` is the vCenter inventory path after the server, without a leading slash.
- `vsphere_folder` is the VM folder path relative to `/<Datacenter>/vm`. For example, if `govc` shows `/Datacenter/vm/Labs/GOAD`, set `vsphere_folder = Labs/GOAD`.
- `vsphere_resource_pool` is optional. If you deploy into a custom resource pool, include it in `vsphere_ovftool_target` as `Datacenter/host/Cluster/Resources/PoolName`.

You can inspect resource pools with:

```bash
govc ls "/${GOVC_DATACENTER}/host/Cluster/Resources"
```

For a single ESXi host managed directly, `vsphere_ovftool_target` can stay empty. For vCenter, set it to a datacenter/host/cluster path:

```ini
vsphere_ovftool_target = Datacenter/host/Cluster
vsphere_ovftool_target = Datacenter/host/Cluster/esxi.example.local
vsphere_ovftool_target = Datacenter/host/Cluster/Resources/PoolName
```

Configure guest network bootstrap according to the lab subnet:

```ini
vsphere_ipv4_gateway = 192.168.56.1
vsphere_ipv4_prefix_length = 24
vsphere_dns_server = 192.168.56.1
```

For example, use `vsphere_ipv4_prefix_length = 27` for a `/27` lab network. If `vsphere_ipv4_gateway` or `vsphere_dns_server` is empty, GOAD derives it from `-ip` as `<ip_range>.1`.

After editing the file, run:

```bash
./goad.sh -t check -l GOAD -p vsphere -ip 192.168.56
```

## Installation

```bash
# check prerequisites
./goad.sh -t check -l GOAD -p vsphere -ip 192.168.56

# install
./goad.sh -t install -l GOAD -p vsphere -ip 192.168.56
```

The `-ip` value is still the first three octets used by GOAD inventories. The subnet mask used during vSphere guest customization is controlled by `vsphere_ipv4_prefix_length`.

The first-boot network bootstrap uses VMware Tools guest operations. If that is disabled, the imported boxes must already be reachable at the inventory IPs before Ansible starts.
