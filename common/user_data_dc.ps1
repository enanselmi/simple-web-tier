<powershell>
$password = $(aws secretsmanager get-secret-value --secret-id password_windows --query SecretString --output text | ConvertFrom-Json) 
$password = $password.password_windows | ConvertTo-SecureString -AsPlainText -Force
new-localuser -name "localadmin" -password $password
add-localgroupmember -group "Remote Desktop Users" -member "localadmin"
add-localgroupmember -group "Administrators" -member "localadmin"

function prereq {    
    $command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
    Invoke-Expression $command
    Invoke-WebRequest -Uri "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi" -Outfile C:\amazon-cloudwatch-agent.msi
    $arguments = "/i `"C:\amazon-cloudwatch-agent.msi`" /quiet"
    Start-Process msiexec.exe -ArgumentList $arguments -Wait    
}
prereq

& "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a fetch-config -m ec2 -s -c ssm:WindowsAgentConfig

</powershell>
