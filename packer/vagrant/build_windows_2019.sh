#!/bin/bash

# ISO link :
# https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso

echo "build vmware windows server 2019 box"
packer build \
  --only=vmware-iso \
  --var vhv_enable=true \
  --var iso_url=~/Téléchargements/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso \
  windows_2019.json

echo "build virtualbox windows server 2019 box"
packer build \
  --only=virtualbox-iso \
  --var vhv_enable=true \
  --var iso_url=~/Téléchargements/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso \
  windows_2019.json
