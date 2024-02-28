param (
  [Parameter(Mandatory,HelpMessage="Task to execute: check,install")]
  [ValidateSet("check","install","status","start","stop","destroy","restart","snapshot","resume","suspend","validate","purge","isolate","de_isolate", IgnoreCase = $true)]
  [Alias('t')]
  [string]$TASK,
  [Parameter(Mandatory,HelpMessage="Lab to use: GOAD, GOAD-light, NHA")]
  [ValidateSet("GOAD","GOAD-light","NHA", IgnoreCase = $true)]
  [Alias('l')]
  [string]$LAB,
  [Parameter(Mandatory,HelpMessage="Provider to use: virtualbox, vmware, azure, proxmox")]
  [ValidateSet("virtualbox","vmware","azure","proxmox", IgnoreCase = $true)]
  [Alias('p')]
  [string]$PROVIDER,
  [Parameter(Mandatory,HelpMessage="Method to use: podman, docker")]
  [ValidateSet("podman","docker", IgnoreCase = $true)]
  [Alias('m')]
  [string]$METHOD,
  [Parameter(Mandatory=$false,HelpMessage="Install kali/rolling: `$True/`$False/O (only)")]
  [ValidateSet($true,$false,"O", IgnoreCase = $true)]
  [Alias('k')]
  [string]$KALI,
  [Parameter(Mandatory=$false,HelpMessage="Enable GUI on Provider: `$True/`$False or 1/0")]
  [ValidateSet($true,$false, IgnoreCase = $true)]
  [Alias('g')]
  [bool]$GUI
)

# Global variables
$ERROR = "[!]"
$OK    = "[x]"
$ADD   = "[+]"
$INFO  = "[-]"

# install VMs into provider
function install_providing{
  Push-Location
  try{
    switch( $PROVIDER )
    {
      {("virtualbox") -or ("vmware")} {
        cd "ad/$LAB/providers/$PROVIDER"
        $VAGRANT_COMMAND="vagrant"
        if ($KALI -eq $True){ $VAGRANT_COMMAND+=" --with-optional-boxes" }
        if ($KALI -eq "O"){ $VAGRANT_COMMAND+=" --only-optional-boxes" }
        if ($GUI -eq $True){ $VAGRANT_COMMAND+=" --with-gui" }
        $VAGRANT_COMMAND+=" up"
        Write-Output "$OK launch vagrant: $VAGRANT_COMMAND"
        iex($VAGRANT_COMMAND)
        if ($LASTEXITCODE -ne 0){
          Write-Output "$ERROR vagrant finish with error abort"
          exit 1
        }
      }
    }
  }finally{
    Pop-Location
  }
}

# build goadansible container if required
function build_container{
  $ALREADY_BUILD=iex("$METHOD images | findstr ""goadansible""")
  if (-not $ALREADY_BUILD){
    Write-Output "$ADD Build container: $METHOD build -t goadansible ."
    $BUILD=iex("$METHOD build -t goadansible .")
    if ($LASTEXITCODE -ne 0){
      Write-Output "$ERROR $METHOD build failed"
      exit 1
    }
    Write-Output "$OK Container goadansible creation complete"
  }
}

function run_ansible($command){
  $template =
  "$METHOD run -ti --rm --network host -h goadansible -v $($PSScriptRoot):/goad -w /goad/ansible goadansible /bin/bash -c ""$command"""
  Write-Output "$template"
  iex($template)
}

function isolate(){
  switch( $PROVIDER )
  {
    {("virtualbox") -or ("vmware") -or ("proxmox")} {
        Write-Output "$INFO Isolation only disables vagrant NAT interface. You have to manually disconnect the host from GOAD network. E.g. vmware: Virtual Network Editor>VMNetX (192.168.56.0)>Uncheck 'Connect a host virtual network adapter to this network'"
        build_container
        run_ansible("ansible-playbook -i ../ad/$LAB/data/inventory -i ../ad/$LAB/providers/$PROVIDER/inventory disable_nat.yml")
    }
  }
}

function de_isolate(){
  switch( $PROVIDER )
  {
    {("virtualbox") -or ("vmware") -or ("proxmox")} {
        Write-Output "$INFO De-Isolation only enables vagrant NAT interface. You have to manually connect the host to GOAD network again. E.g. vmware: Virtual Network Editor>VMNetX (192.168.56.0)>Check 'Connect a host virtual network adapter to this network'"
        build_container
        run_ansible("ansible-playbook -i ../ad/$LAB/data/inventory -i ../ad/$LAB/providers/$PROVIDER/inventory enable_nat.yml")
    }
  }
}

# configure VMs on provider
function install_provisioning{
  switch( $PROVIDER )
  {
    {("virtualbox") -or ("vmware") -or ("proxmox")} {
      Write-Output "$INFO successful provisioning tested only for vmware. Virtualbox: hanging VMs. Proxmox: not tested. Providers are kept for testing purposed only."
      build_container
      Write-Output "$OK Start provisioning from $METHOD"
      Write-Output "$PSScriptRoot"
      run_ansible("ANSIBLE_COMMAND='ansible-playbook -i ../ad/$LAB/data/inventory -i ../ad/$LAB/providers/$PROVIDER/inventory' ../scripts/provisionning.sh")
    }
  }
}

# issue vagrant command for VMs on provider
function vagrant_command($command){
  switch( $PROVIDER )
  {
    {("virtualbox") -or ("vmware")} {
      Push-Location
      try{
        cd "ad/$LAB/providers/$PROVIDER"
        $VAGRANT_COMMAND="vagrant"
        if ($KALI -eq $True){ $VAGRANT_COMMAND+=" --with-optional-boxes" }
        if ($KALI -eq "O"){ $VAGRANT_COMMAND+=" --only-optional-boxes" }
        if ($GUI -eq $True){ $VAGRANT_COMMAND+=" --with-gui" }
        $VAGRANT_COMMAND+=" $command"
        Write-Output "$OK vagrant command: $VAGRANT_COMMAND"
        iex($VAGRANT_COMMAND)
      }finally{
        Pop-Location
      }
    }
  }
}

#Check-function
function check {
  Write-Output "$OK Launch check : ./scripts/check.ps1 $PROVIDER $METHOD"
  & $PSScriptRoot\scripts\check.ps1 $PROVIDER $METHOD 
  if ($LASTEXITCODE -eq 0){
    Write-Output "$OK Check is ok, you can start the installation"
  } else {
    Write-Output "$ERROR Check is not ok, please fix the errors and retry"
    Write-Output "$INFO You could also run the setup script"
  } 
}

#Install-function
function install {
  Write-Output "$OK Launch installation for: $LAB / $PROVIDER / $METHOD"
  install_providing
  install_provisioning
}

#Main-function
function main {
  # Remember current directory
  Push-Location
  
  # switch to script directory
  cd $PSScriptRoot

  switch( $TASK )
  {
    check { check }
    install { install }
    status { vagrant_command("status") }
    start { vagrant_command("up") }
    stop { vagrant_command("halt") }
    destroy { vagrant_command("destroy") }
    purge { vagrant_command("destroy -f") }
    restart { vagrant_command("reload") }
    snapshot { vagrant_command("snapshot") }
    resume { vagrant_command("resume") }
    suspend { vagrant_command("suspend") }
    validate { vagrant_command("validate") }
    isolate { isolate }
    de_isolate { de_isolate }
    default { Write-Output "unknow option for TASK" } # NOT required as param([ValidateSet()] takes care
  }

  # Return to the previous directory 
  Pop-Location
}

#Entry point
main