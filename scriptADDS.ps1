Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature

# Création Domain Nova Tech
Install-ADDSForest -DomainName "NovaTechSolutionsMMMR.local" -SafeModeAdministratorPassword (ConvertTo-SecureString "Test1234" -AsPlainText -Force) 
-DomainMode Win2019 -ForestMode Win2019 -InstallDns


# Joindre Win10 domaine
$DomainName = "NovaTechSolutionsMMMR.local"
$Credential = Get-Credential
Add-Computer -DomainName $DomainName -Credential $Credential -Restart