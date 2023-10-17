param(
    [string]$pathdata,
    [string]$sharedFolder
)
Import-Module ActiveDirectory
Import-Module ImportExcel

    $users = Import-Excel -Path $pathdata
    $regexPattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*\W).{8,}$"

    foreach ($user in $users) {
        if ($user.'mot de passe' -match $regexPattern) {
            try {
                Add-ADUser -SamAccountName $user.'samAccountName' -AccountPassword (ConvertTo-SecureString $user.'mot de passe' -AsPlainText -Force) -PasswordNeverExpires $true
                Write-Output "Utilisateur $($user.'Nom') a été ajouté"
            }
            catch {
                Write-Host "Impossible d'ajouté l'utilisateur : $($user.'Nom')"
            }
        } else {
            Write-Output "Utilisateur $($user.'Nom') ne peut pas être ajouté"
        }
    }


    # Creation des types de groupe
    $groupeUnique = $users | Select-Object -ExpandProperty 'Groupe' -Unique

    $dossierPartage = $sharedFolder

foreach ($groupName in $groupeUnique) {
    if (-not (Get-ADGroup -Filter { Name -eq $groupName })) {
        try {
            New-ADGroup -Name $groupName -GroupScope Global -GroupCategory Security -Path "OU=OrganizationalUnit,DC=Domain,DC=com"
            Write-Output "Groupe '$groupName' créé"

            $groupeFolderPath = Join-Path -Path $dossierPartage -ChildPath $groupName
            if (!(Test-Path -Path $groupeFolderPath -PathType Container)) {
                New-Item -Path $groupeFolderPath -ItemType Directory

                # Autorisations
                $groupe = Get-ADGroup $groupName
                $groupSID = New-Object System.Security.Principal.SecurityIdentifier($groupe.SID)
                $acl = Get-Acl $groupeFolderPath
                $permission = New-Object System.Security.AccessControl.FileSystemAccessRule($groupSID, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
                $acl.SetAccessRule($permission)
                Set-Acl $groupeFolderPath $acl
                New-SmbShare -Name $groupName -Path $groupeFolderPath -FullAccess $groupName
                Write-Output "Dossier partagé $($groupName) a été créé"
            }
            else {
                Write-Output "Ce dossier partagé existe déjà."
            }

        }
        catch {
            Write-Host "Impossible d'ajouter le groupe $($groupName)"
        }
    }
    else {
        Write-Output "Le groupe $($groupName) existe déjà"
    }
}