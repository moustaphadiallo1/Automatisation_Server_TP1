$Username = "administrateur"
$NewPassword = ConvertTo-SecureString "Test1234" -AsPlainText -Force

Set-LocalUser -Name $Username -Password $NewPassword