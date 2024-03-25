#!/bin/bash

# transform files into iso, because proxmox only accept iso and no floppy A:\

echo "[+] Build iso windows 10 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_windows10_cloudinit.iso answer_files/10_proxmox_cloudinit
sha_win10=$(sha256sum ./iso/Autounattend_windows10_cloudinit.iso|cut -d ' ' -f1)
echo "[+] update windows_10_22h2_proxmox_cloudinit.pkvars.hcl"
sed -i "s/\"sha256:.*\"/\"sha256:$sha_win10\"/g" windows_10_22h2_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso windows 10 with cloudinit and update"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_windows10_cloudinit_uptodate.iso answer_files/10_proxmox_cloudinit_uptodate
sha_win10=$(sha256sum ./iso/Autounattend_windows10_cloudinit_uptodate.iso|cut -d ' ' -f1)
echo "[+] update windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i "s/\"sha256:.*\"/\"sha256:$sha_win10\"/g" windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl

echo "[+] Build iso winserver2016 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_winserver2016_cloudinit.iso answer_files/2016_proxmox_cloudinit
sha_winserv2016=$(sha256sum ./iso/Autounattend_winserver2016_cloudinit.iso|cut -d ' ' -f1)
echo "[+] update windows_server2016_proxmox_cloudinit.pkvars.hcl"
sed -i "s/\"sha256:.*\"/\"sha256:$sha_winserv2016\"/g" windows_server2016_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso winserver2019 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_winserver2019_cloudinit.iso answer_files/2019_proxmox_cloudinit
sha_winserv2019=$(sha256sum ./iso/Autounattend_winserver2019_cloudinit.iso|cut -d ' ' -f1)
echo "[+] update windows_server2019_proxmox_cloudinit.pkvars.hcl"
sed -i "s/\"sha256:.*\"/\"sha256:$sha_winserv2019\"/g" windows_server2019_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso winserver2019 with cloudinit and update"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_winserver2019_cloudinit_uptodate.iso answer_files/2019_proxmox_cloudinit_uptodate
sha_winserv2019_update=$(sha256sum ./iso/Autounattend_winserver2019_cloudinit_uptodate.iso|cut -d ' ' -f1)
echo "[+] update windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i "s/\"sha256:.*\"/\"sha256:$sha_winserv2019_update\"/g" windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl

echo "[+] Build iso for scripts"
mkisofs -J -l -R -V "scripts CD" -iso-level 4 -o ./iso/scripts_withcloudinit.iso scripts
# echo "scripts_withcloudinit.iso"
# sha256sum ./iso/scripts_withcloudinit.iso
