<powershell>
$password = $(aws secretsmanager get-secret-value --secret-id password_windows --query SecretString --output text | ConvertFrom-Json) 
$password = $password.password_windows | ConvertTo-SecureString -AsPlainText -Force
new-localuser -name "localadmin" -password $password
add-localgroupmember -group "Remote Desktop Users" -member "localadmin"
add-localgroupmember -group "Administrators" -member "localadmin"
</powershell>
