$User = "viserion@dracarys.lab"
$SSHHost = "syrax"
$Password = "aLHtz1WvIVmeV4Zh4CDE"

& "C:\Program Files\PuTTY\klink.exe" -auto_store_sshkey $SSHHost -l "$User" -pw $Password "sleep 45"
