#cloud-config
users:
  - name: ${username}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    %{ if password != "" } # disable password auth if password not provided
    lock_passwd: false
    plain_text_passwd: ${password}
    %{ endif }
    ssh-authorized-keys:
      - ${key}
