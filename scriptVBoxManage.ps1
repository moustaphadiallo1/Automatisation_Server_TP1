param (
    [string]$ISOPath,
   # [string]$Storage,
    [string]$VMName,
    [int]$VMRAM,
    [string]$OSType
)
$env:PATH = $env:PATH + ";C:\Program Files\Oracle\VirtualBox"

# Liste des noms de machines virtuelles



VBoxManage createvm --name $VMName --ostype $OSType --register

VBoxManage storagectl $VMName --name "SATA Controller" --add sata 

VBoxManage storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type dvddrive --medium $ISOPath

VBoxManage createhd --filename "$Storage\$VMName.vdi" --size 25000
VBoxManage storageattach $VMName --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$Storage\$VMName.vdi"

VBoxManage modifyvm $VMName --memory $VMRAM --cpus 2
