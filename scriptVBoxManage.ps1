param (
    [string]$ISOPath,
    [string]$Storage,
    [string]$VMName,
    [int]$VMRAM
)

# Liste des noms de machines virtuelles
$VMNames = @("${VMName}_SERVER2019", "${VMName}_WIN10")

foreach ($VM in $VMNames) {
    vboxmanage createvm --name $VM --ostype "Windows10_64" --register

    vboxmanage storageattach $VM --storagectl "SATAController" --port 0 --device 0 --type dvddrive --medium $ISOPath

    vboxmanage createhd --filename "$Storage\$VM.vdi" --size 20000
    vboxmanage storageattach $VM --storagectl "SATAController" --port 1 --device 0 --type hdd --medium "$Storage\$VM.vdi"

    vboxmanage modifyvm $VM --memory $VMRAM --cpus 2
}