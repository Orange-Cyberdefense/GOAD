#!/bin/bash

# transform files into iso, because proxmox only accept iso and no floppy A:\

echo "[+] Build iso windows 10 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_windows10_cloudinit.iso answer_files/10_proxmox_cloudinit
sha_win10=$(sha256sum ./iso/Autounattend_windows10_cloudinit.iso|cut -d ' ' -f1)
echo "[+] update windows_10_22h2_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_win10\"/g" windows_10_22h2_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso windows 10 with cloudinit and update"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_windows10_cloudinit_uptodate.iso answer_files/10_proxmox_cloudinit_uptodate
sha_win10_uptodate=$(sha256sum ./iso/Autounattend_windows10_cloudinit_uptodate.iso|cut -d ' ' -f1)
echo "[+] update windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_win10_uptodate\"/g" windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl

echo "[+] Build iso windows 11 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_windows11_cloudinit.iso answer_files/11_proxmox_cloudinit
sha_win11=$(sha256sum ./iso/Autounattend_windows11_cloudinit.iso|cut -d ' ' -f1)
echo "[+] Updating autounattend_checksum in windows_11_24h2_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_win11\"/g" windows_11_24h2_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso windows 11 with cloudinit and update"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_windows11_cloudinit_uptodate.iso answer_files/11_proxmox_cloudinit_uptodate
sha_win11_uptodate=$(sha256sum ./iso/Autounattend_windows11_cloudinit_uptodate.iso|cut -d ' ' -f1)
echo "[+] Updating autounattend_checksum in windows_11_24h2_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_win11_uptodate\"/g" windows_11_24h2_proxmox_cloudinit_uptodate.pkvars.hcl

echo "[+] Build iso winserver2016 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_winserver2016_cloudinit.iso answer_files/2016_proxmox_cloudinit
sha_winserv2016=$(sha256sum ./iso/Autounattend_winserver2016_cloudinit.iso|cut -d ' ' -f1)
echo "[+] update windows_server2016_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_winserv2016\"/g" windows_server2016_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso winserver2016 with cloudinit and update"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_winserver2016_cloudinit_uptodate.iso answer_files/2016_proxmox_cloudinit_uptodate
sha_winserv2016_uptodate=$(sha256sum ./iso/Autounattend_winserver2016_cloudinit_uptodate.iso|cut -d ' ' -f1)
echo "[+] update windows_server2016_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_winserv2016_uptodate\"/g" windows_server2016_proxmox_cloudinit_uptodate.pkvars.hcl

echo "[+] Build iso winserver2019 with cloudinit"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_winserver2019_cloudinit.iso answer_files/2019_proxmox_cloudinit
sha_winserv2019=$(sha256sum ./iso/Autounattend_winserver2019_cloudinit.iso|cut -d ' ' -f1)
echo "[+] update windows_server2019_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_winserv2019\"/g" windows_server2019_proxmox_cloudinit.pkvars.hcl

echo "[+] Build iso winserver2019 with cloudinit and update"
mkisofs -J -l -R -V "autounatend CD" -iso-level 4 -o ./iso/Autounattend_winserver2019_cloudinit_uptodate.iso answer_files/2019_proxmox_cloudinit_uptodate
sha_winserv2019_update=$(sha256sum ./iso/Autounattend_winserver2019_cloudinit_uptodate.iso|cut -d ' ' -f1)
echo "[+] update windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i -E "s/(autounattend_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_winserv2019_update\"/g" windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl

echo "[+] Checking and downloading CloudbaseInitSetup file..."
if [ ! -f "scripts/sysprep/CloudbaseInitSetup_x64.msi" ]; then
    wget https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi -O scripts/sysprep/CloudbaseInitSetup_x64.msi
else
    echo "[*] CloudbaseInitSetup_x64.msi already exists. Skipping download."
fi

echo "[+] Build iso for scripts"
mkisofs -J -l -R -V "scripts CD" -iso-level 4 -o ./iso/scripts_windows_cloudinit.iso scripts
sha_scripts=$(sha256sum ./iso/scripts_windows_cloudinit.iso | cut -d ' ' -f1)
echo "[+] Updating scripts_checksums"
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_10_22h2_proxmox_cloudinit.pkvars.hcl
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_11_24h2_proxmox_cloudinit_uptodate.pkvars.hcl
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_11_24h2_proxmox_cloudinit.pkvars.hcl
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_server2016_proxmox_cloudinit_uptodate.pkvars.hcl
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_server2016_proxmox_cloudinit.pkvars.hcl
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl
sed -i -E "s/(scripts_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_scripts\"/g" windows_server2019_proxmox_cloudinit.pkvars.hcl

echo "[+] Checking and downloading VirtIO driver file..."
if [ ! -f "iso/goadv3_virtio_win.iso" ]; then
    wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso -O iso/goadv3_virtio_win.iso
else
    echo "[*] goadv3_virtio_win.iso already exists. Skipping download."
fi

# Update checksum for VirtIO ISO
if [ -f "iso/goadv3_virtio_win.iso" ]; then
    sha_virtio=$(sha256sum ./iso/goadv3_virtio_win.iso | cut -d ' ' -f1)
    echo "[+] Updating virtio_checksum in windows_11_24h2_proxmox_cloudinit.pkvars.hcl"
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_10_22h2_proxmox_cloudinit.pkvars.hcl
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_11_24h2_proxmox_cloudinit_uptodate.pkvars.hcl
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_11_24h2_proxmox_cloudinit.pkvars.hcl
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_server2016_proxmox_cloudinit_uptodate.pkvars.hcl
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_server2016_proxmox_cloudinit.pkvars.hcl
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl
    sed -i -E "s/(virtio_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_virtio\"/g" windows_server2019_proxmox_cloudinit.pkvars.hcl
fi


echo "[+] Checking and downloading Windows ISO files..."
if [ ! -f "iso/windows-10-22h2_x64_en-us.iso" ]; then
    wget https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso -O iso/windows-10-22h2_x64_en-us.iso
else
    echo "[*] windows-10-22h2_x64_en-us.iso already exists. Skipping download."
fi

if [ ! -f "iso/windows-11-24h2_x64_en-us.iso" ]; then
    wget https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso -O iso/windows-11-24h2_x64_en-us.iso
else
    echo "[*] windows-11-24h2_x64_en-us.iso already exists. Skipping download."
fi

if [ ! -f "iso/windows_server_2016_14393.0_eval_x64.iso" ]; then
    wget https://software-static.download.prss.microsoft.com/pr/download/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO -O iso/windows_server_2016_14393.0_eval_x64.iso
else
    echo "[*] windows_server_2016_14393.0_eval_x64.iso already exists. Skipping download."
fi

if [ ! -f "iso/windows_server2019_x64FREE_en-us.iso" ]; then
    wget https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso -O iso/windows_server2019_x64FREE_en-us.iso
else
    echo "[*] windows_server2019_x64FREE_en-us.iso already exists. Skipping download."
fi


sha_iso_win10=$(sha256sum ./iso/windows-10-22h2_x64_en-us.iso | cut -d ' ' -f1)
sha_iso_win11=$(sha256sum ./iso/windows-11-24h2_x64_en-us.iso | cut -d ' ' -f1)
sha_iso_winserv2016=$(sha256sum ./iso/windows_server_2016_14393.0_eval_x64.iso | cut -d ' ' -f1)
sha_iso_winserv2019=$(sha256sum ./iso/windows_server2019_x64FREE_en-us.iso | cut -d ' ' -f1)

echo "[+] Updating iso_checksums in windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_win10\"/g" windows_10_22h2_proxmox_cloudinit_uptodate.pkvars.hcl
echo "[+] Updating iso_checksums in windows_10_22h2_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_win10\"/g" windows_10_22h2_proxmox_cloudinit.pkvars.hcl
echo "[+] Updating iso_checksums in windows_11_24h2_proxmox_cloudinit_uptodate.pkvars.hcl"  
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_win11\"/g" windows_11_24h2_proxmox_cloudinit_uptodate.pkvars.hcl
echo "[+] Updating iso_checksums in windows_11_24h2_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_win11\"/g" windows_11_24h2_proxmox_cloudinit.pkvars.hcl
echo "[+] Updating iso_checksums in windows_server2016_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_winserv2016\"/g" windows_server2016_proxmox_cloudinit_uptodate.pkvars.hcl
echo "[+] Updating iso_checksums in windows_server2016_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_winserv2016\"/g" windows_server2016_proxmox_cloudinit.pkvars.hcl
echo "[+] Updating iso_checksums in windows_server2016_proxmox_cloudinit_uptodate.pkvars.hcl"
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_winserv2019\"/g" windows_server2019_proxmox_cloudinit_uptodate.pkvars.hcl
echo "[+] Updating iso_checksums in windows_server2019_proxmox_cloudinit.pkvars.hcl"
sed -i -E "s/(iso_checksum\s*=\s*)\"sha256:[a-f0-9]*\"/\1\"sha256:$sha_iso_winserv2019\"/g" windows_server2019_proxmox_cloudinit.pkvars.hcl