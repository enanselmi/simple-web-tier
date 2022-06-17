<powershell>
$password = $(aws secretsmanager get-secret-value --secret-id password_windows --query SecretString --output text | ConvertFrom-Json) 
$password = $password.password_windows | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("contoso\administrator",$password)
Add-Computer -DomainName "contoso.local" -Credential $credential -Restart
</powershell>