param(
    [string]$pathData,
    [string]$destinationPath
)

Import-Module ImportExcel
$usersGroup = Import-Excel -Path $pathData

# creation des txt pour les script de connexion
foreach ($user in $usersGroup) {
    $groupName = $user.'Groupe'

    # ici il va falloir changer et mettre le bon
    $filePath = Join-Path -Path $destinationPath -ChildPath "$($groupName).txt"
    
   "Hello members of the group $($groupName)" | Out-File -Append -FilePath $filePath
    Write-Output "Group name $($groupName) has been added"
}


# Association des scripts de connexion aux GPO
foreach ($user in $usersGroup) {
    $groupName = $user.'Groupe'
    $scriptPath = Join-Path -Path $destinationPath -ChildPath "$($groupName)_LoginScript.ps1"
    $filePath = Join-Path -Path $destinationPath -ChildPath "$($groupName).txt"

    if (Test-Path -Path $filePath -PathType Leaf) {
        try {

            $fileContent = Get-Content -Path $filePath

            Write-Output $fileContent | Out-File -Append -FilePath $scriptPath
            Write-Output "Le script a été crée"
    
            $gpoName = "GPO_Groupe_$($groupName)"
            New-GPO -Name $gpoName
        
            # Lier la GPO à l'OU appropriée
            $pathajoutGPO = "OU=NomDeVotreOU,DC=Domaine,DC=com"  
            New-GPLink -Name $gpoName -Target $pathajoutGPO
    
            Write-Output "GPO $($gpoName) a été cree et associé avec succès"
        }
        catch {
           Write-Host "Impossible de creer le script"
        }
    } else {
        Write-Output "Le fichier texte existe deja"
    }
}


