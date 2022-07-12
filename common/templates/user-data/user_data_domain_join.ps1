<powershell>
$password = $(aws secretsmanager get-secret-value --secret-id password_windows --query SecretString --output text | ConvertFrom-Json) 
$password = $password.password_windows | ConvertTo-SecureString -AsPlainText -Force
Set-LocalUser -Name administrator -Password $password -Verbose
$credential = New-Object System.Management.Automation.PSCredential("contoso\administrator",$password)
Add-Computer -DomainName "contoso.com" -Credential $credential -Restart
</powershell>