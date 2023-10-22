#!/bin/bash

echo "build vmware windows 10 box"
packer build --only=vmware-iso \
   --var iso_url=~/Téléchargements/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso \
  windows_10.json

echo "build virtualbox windows 10 box"
packer build --only=virtualbox-iso \
  --var iso_url=~/Téléchargements/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso \
  windows_10.json

