param (
  [Parameter(Mandatory,HelpMessage="Provider to use: virtualbox, vmware, azure, proxmox")]
  [ValidateSet("virtualbox","vmware","azure","proxmox", IgnoreCase = $false)]
  [Alias('p')]
  [string]$PROVIDER,
  [Parameter(Mandatory,HelpMessage="Method to use: podman, docker")]
  [ValidateSet("podman","docker", IgnoreCase = $false)]
  [Alias('m')]
  [string]$METHOD
)

# Global variables
$ERROR = "[!]"
$OK    = "[x]"
$INFO  = "[-]"
$INDENT = "   "

function check_vmware_workstation_installed(){
  # Check for VMware Workstation through Win32 API
  $vmwareInstalled = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'VMware Workstation%'" -ErrorAction SilentlyContinue
  if ($vmwareInstalled -ne $null) {
    Write-Output "$OK VMware is installed."
  } else {
    Write-Output "$ERROR VMware is not installed."
    Write-Output "$ERROR Correct this by installing vmware."
    Write-Output "$INFO Check installation with `n$INDENT PS> Get-WmiObject -Query ""SELECT * FROM Win32_Product WHERE Name LIKE 'VMware Workstation%'"
  }
}

function check_vagrant_path(){
  try {
    if(Get-Command vagrant -ErrorAction Stop){
      Write-Output "$OK Vagrant was found in your PATH"
      # Ensure Vagrant >= 2.2.9
      # https://unix.stackexchange.com/a/285928
      $VAGRANT_VERSION = iex('vagrant --version | ForEach-Object {$_.split(" ")[1]}')
      $REQUIRED_VERSION="2.2.9"
      # If the version of Vagrant is not greater or equal to the required version
      if ([System.Version]$VAGRANT_VERSION -lt [System.Version]$REQUIRED_VERSION){
        Write-Output "$ERROR WARNING: It is highly recommended to use Vagrant $REQUIRED_VERSION or above before continuing"
		Exit 1
      }else{
        Write-Output "$OK Your version of Vagrant ($VAGRANT_VERSION) is supported"
      }
    }
  } Catch {
    Write-Output "$ERROR Vagrant was not found in your PATH."
    Write-Output "$ERROR Please correct this before continuing. Exiting."
    Write-Output "$ERROR Correct this by installing Vagrant : https://www.vagrantup.com/downloads.html"
    Exit 1  
  }
}

function check_vagrant_reload_plugin{
  $VAGRANT_RELOAD_PLUGIN_INSTALLED=iex('vagrant plugin list | findstr "vagrant-reload"')
  if ($VAGRANT_RELOAD_PLUGIN_INSTALLED){
    Write-Output "$OK The vagrant-reload plugin is currently installed"
  }else{
    Write-Output "$ERROR The vagrant-reload plugin is required and was not found. This script will attempt to install it now with:`nPS> vagrant plugin install 'vagrant-reload'"
    if (-Not (iex('vagrant plugin install "vagrant-reload"'))){
      Write-Output "$ERROR Unable to install the vagrant-reload plugin. Please try to do so manually and re-run this script."
	  Exit 1
    }else{
      Write-Output "$OK The vagrant-reload plugin was successfully installed!"
    }
  }
}

function check_vagrant_vmware_utility_installed(){
  # Ensure the helper utility is installed: https://www.vagrantup.com/docs/providers/vmware/vagrant-vmware-utility
  $VMWARE_UTILITY_INSTALLED=(Get-Service vagrant-vmware-utility -ErrorAction SilentlyContinue)
  if (($VMWARE_UTILITY_INSTALLED) -and $VMWARE_UTILITY_INSTALLED.Count -eq 1){
    Write-Output "$OK vagrant-vmware-utility installed"
  }else{
    Write-Output "$ERROR vagrant-vmware-utility is not installed (https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility)"
	Exit 1
  }
}

function check_vagrant_vmware_desktop_plugin{
  $VAGRANT_VMWARE_DESKTOP_PLUGIN_INSTALLED=iex('vagrant plugin list | findstr "vagrant-vmware-desktop"')
  if ($VAGRANT_VMWARE_DESKTOP_PLUGIN_INSTALLED){
    Write-Output "$OK The vagrant-vmware-desktop plugin is currently installed"
  }else{
    Write-Output "$ERROR The vagrant-vmware-desktop plugin is required and was not found. This script will attempt to install it now with:`nPS> vagrant plugin install 'vagrant-vmware-desktop'"
    if (-Not (iex('vagrant plugin install "vagrant-vmware-desktop"'))){
      Write-Output "$ERROR Unable to install the vagrant-vmware-desktop plugin. Please try to do so manually and re-run this script."
	  Exit 1
    }else{
      Write-Output "$OK The vagrant-vmware-desktop plugin was successfully installed!"
    }
  }
}

function check_disk_free_space(){
  if ((Get-Volume -DriveLetter C).Size/1GB -lt 120){
    Write-Output "$INFO Warning: You appear to have less than 120GB of HDD space free on your primary partition. If you are using a separate parition, you may ignore this warning."
  }else{
    Write-Output "$OK You have more than 120GB of free space on your primary partition"
  }
}

function check_ram_space(){
  if ((Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum/1GB -lt 24){
    Write-Output "$INFO Warning: You appear to have less than 24GB of RAM on your disk, you should consider running only a part of the lab."
  }else{
    Write-Output "$OK You have more than 24GB of ram"
  }
}

function check_podman_installed(){
  try{
    if ((Get-Command podman -ErrorAction Stop).Count -gt 0){
      Write-Output "$OK podman is installed"
    }
  }catch{
    Write-Output "$ERROR podman was not found in your PATH."
	Exit 1
  }
}

function check_docker_installed(){
  try{
    if ((Get-Command docker -ErrorAction Stop).Count -gt 0){
      Write-Output "$OK docker is installed"
    }
  }catch{
    Write-Output "$ERROR docker was not found in your PATH."
	Exit 1
  }
}

#Main-function
function main {
  # Remember current directory
  Push-Location
  
  # switch to script directory
  cd $PSScriptRoot

  switch( $PROVIDER )
  {
    virtualbox { check }
    vmware { 
      Write-Output "[+] Enumerating vmware"
      check_vmware_workstation_installed
      check_vagrant_path
      check_vagrant_reload_plugin
      check_vagrant_vmware_utility_installed
      check_vagrant_vmware_desktop_plugin
      check_disk_free_space
      check_ram_space
      switch ( $METHOD ){
        docker { check_docker_installed }
        podman { check_podman_installed }
      }
    }
    azure { check }
    proxmox { check }
    default { print usage } # NOT required as param([ValidateSet()] takes care
  }

  # Return to the previous directory 
  Pop-Location
}

#Entry point
main

EXIT