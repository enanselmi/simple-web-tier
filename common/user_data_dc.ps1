<powershell>
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module AWSPowerShell -Confirm:$False -Force
$password2 = $(aws secretsmanager get-secret-value --secret-id password_windows | ConvertTo-SecureString -AsPlainText -Force)
new-localuser -name "localadmin2" -password $password2
add-localgroupmember -group "Remote Desktop Users" -member "localadmin2"
add-localgroupmember -group "Administrators" -member "localadmin2"
</powershell>
