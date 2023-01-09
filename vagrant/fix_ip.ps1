# vmware bug to set the ip
# see : https://github.com/hashicorp/vagrant/issues/5000#issuecomment-258209286

param ([String] $ip)

netsh.exe int ip set address Ethernet1 static $ip 255.255.255.0
