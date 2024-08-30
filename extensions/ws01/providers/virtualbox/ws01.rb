def ws01(boxes)
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