Vagrant.configure("2") do |config|

boxes = [
  # windows server 2022 : don't work for now
  #{ :name => "DC01",  :ip => "192.168.56.10", :box => "StefanScherer/windows_2022", :box_version => "2021.08.23", :os => "windows"},
  # windows server 2019
  { :name => "DC01",  :ip => "192.168.56.10", :box => "StefanScherer/windows_2019", :box_version => "2021.05.15", :os => "windows"},
  # windows server 2019
  { :name => "DC02",  :ip => "192.168.56.11", :box => "StefanScherer/windows_2019", :box_version => "2021.05.15", :os => "windows"},
  # windows server 2016
  { :name => "DC03",  :ip => "192.168.56.12", :box => "StefanScherer/windows_2016", :box_version => "2017.12.14", :os => "windows"},
  # windows server 2019
  #{ :name => "SRV01", :ip => "192.168.56.21", :box => "StefanScherer/windows_2019", :box_version => "2020.07.17", :os => "windows"},
  # windows server 2019
  { :name => "SRV02", :ip => "192.168.56.22", :box => "StefanScherer/windows_2019", :box_version => "2020.07.17", :os => "windows"},
  # windows server 2016
  { :name => "SRV03", :ip => "192.168.56.23", :box => "StefanScherer/windows_2016", :box_version => "2019.02.14", :os => "windows"}
  # ELK
# { :name => "elk", :ip => "192.168.56.50", :box => "bento/ubuntu-18.04", :os => "linux",
#   :forwarded_port => [
#     {:guest => 22, :host => 2210, :id => "ssh"}
#   ]
# }
]

# BUILD with a full up to date vm if you don't want version with old vulns 
# ansible versions boxes : https://app.vagrantup.com/jborean93
# boxes = [
#   # windows server 2019
#   { :name => "DC01",  :ip => "192.168.56.10", :box => "jborean93/WindowsServer2019", :os => "windows"},
#   # windows server 2019
#   { :name => "DC02",  :ip => "192.168.56.11", :box => "jborean93/WindowsServer2019", :os => "windows"},
#   # windows server 2016
#   { :name => "DC03",  :ip => "192.168.56.12", :box => "jborean93/WindowsServer2016", :os => "windows"},
#   # windows server 2019
#   { :name => "SRV02", :ip => "192.168.56.22", :box => "jborean93/WindowsServer2019", :os => "windows"},
#   # windows server 2016
#   { :name => "SRV03", :ip => "192.168.56.23", :box => "jborean93/WindowsServer2016", :os => "windows"}
# ]

  config.vm.provider "virtualbox" do |v|
    v.memory = 3000
    v.cpus = 2
  end

  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = "2"
  end

  # no autoupdate if vagrant-vbguest is installed
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.boot_timeout = 600
  config.vm.graceful_halt_timeout = 600
  config.winrm.retry_limit = 30
  config.winrm.retry_delay = 10

  boxes.each do |box|
    config.vm.define box[:name] do |target|
      # BOX
      target.vm.box = box[:box]
      if box.has_key?(:box_version)
        target.vm.box_version = box[:box_version]
      end

      # IP
      target.vm.network :private_network, ip: box[:ip]

      # OS specific
      if box[:os] == "windows"
        target.vm.guest = :windows
        target.vm.communicator = "winrm"
        target.vm.provision :shell, :path => "vagrant/Install-WMF3Hotfix.ps1", privileged: false
        target.vm.provision :shell, :path => "vagrant/ConfigureRemotingForAnsible.ps1", privileged: false
      else
        target.vm.communicator = "ssh"
      end

      # forwarded port
      if box.has_key?(:forwarded_port)
        box[:forwarded_port] do |forwarded_port|
          target.vm.network :forwarded_port, guest: forwarded_port[:guest], host: forwarded_port[:host], id: forwarded_port[:id]
        end
      end

    end
  end
end
