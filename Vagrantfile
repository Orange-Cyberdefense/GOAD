Vagrant.configure("2") do |config|

# versions available : https://app.vagrantup.com/StefanScherer/boxes/windows_10
  boxes = [
    { :name => "kingslanding", :ip => "192.168.56.10", :box => "StefanScherer/windows_2019", :box_version => "2021.05.15", :os => "windows",
      :forwarded_port => [
        {:guest => 3389, :host => 23389, :id => "msrdp"},
        {:guest => 5985, :host => 25985, :id => "winrm"}
      ]
    },
    { :name => "dragonstone", :ip => "192.168.56.11", :box => "StefanScherer/windows_2016", :box_version => "2017.12.14", :os => "windows",
      :forwarded_port => [
        {:guest => 3389, :host => 33389, :id => "msrdp"},
        {:guest => 5985, :host => 35985, :id => "winrm"}
      ]
    },
    { :name => "winterfell", :ip => "192.168.56.20", :box => "StefanScherer/windows_2019", :box_version => "2020.07.17", :os => "windows",
      :forwarded_port => [
        {:guest => 3389, :host => 43389, :id => "msrdp"},
        {:guest => 5985, :host => 45985, :id => "winrm"}
      ] 
    },
    { :name => "elk", :ip => "192.168.56.50", :box => "bento/ubuntu-18.04", :os => "linux",
      :forwarded_port => [
        {:guest => 22, :host => 2210, :id => "ssh"}
      ]
    }
  ]
#  ,
#    { :name => "highgarden", :ip => "192.168.56.30", :box => "win7/box/windows7_pro.box", :os => "windows",
#      :forwarded_port => [
#        {:guest => 3389, :host => 33389, :id => "msrdp"},
#        {:guest => 5985, :host => 35985, :id => "winrm"}
#      ]
#    }
#  ]

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "1024"
    v.vmx["numvcpus"] = "1"
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
