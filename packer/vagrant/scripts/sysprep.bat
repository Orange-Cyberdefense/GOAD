rem net stop tiledatamodelsvc
if exist a:\unattend.xml (
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:a:\unattend.xml
) else (
  del /F \Windows\System32\Sysprep\unattend.xml
  c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet  
)
