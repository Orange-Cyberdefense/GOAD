def _template(boxes)
  # add linux box
  boxes.append(
      { :name => "_template",
        :ip => "192.168.56.56",
        :box => "bento/ubuntu-22.04",
        :os => "linux",
        :forwarded_port => [ {:guest => 22, :host => 2210, :id => "ssh"} ]
      }
  )

  # add windows box
  boxes.append(
    { :name => "GOAD-WS01",
      :ip => "192.168.56.31",
      :box => "mayfly/windows10",
      :os => "windows"
    }
  )

  boxes
end