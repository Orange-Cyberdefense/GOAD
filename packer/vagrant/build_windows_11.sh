#!/bin/bash

echo "build vmware windows 11 box"
packer build --only=vmware-iso \
  --var iso_url=~/Téléchargements/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso \
  windows_11.json

echo "build virtualbox windows 11 box"
packer build --only=virtualbox-iso \
  --var iso_url=~/Téléchargements/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso \
  windows_11.json