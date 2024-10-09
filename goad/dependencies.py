from goad.utils import Utils


class Dependencies:
    # Can change enabled providers (useful if you don't want some dependencies)
    vmware_enabled = True
    virtualbox_enabled = True
    azure_enabled = True
    aws_enabled = True
    proxmox_enabled = True
    ludus_enabled = True
    # Can change enabled provisioners (useful if you don't want some dependencies)
    provisioner_local_enabled = True
    provisioner_runner_enabled = True
    provisioner_remote_enabled = True
    provisioner_docker_enabled = False if Utils.is_wsl() else True
