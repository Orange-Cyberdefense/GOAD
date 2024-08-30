def elk(boxes)
  boxes.append(
      { :name => "ELK",
        :ip => "192.168.56.50",
        :box => "bento/ubuntu-22.04",
        :os => "linux",
        :forwarded_port => [ {:guest => 22, :host => 2210, :id => "ssh"} ]
      }
  )
  boxes
end