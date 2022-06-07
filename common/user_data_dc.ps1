<powershell>
function prereq {    
        $command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
        Invoke-Expression $command
        Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -Outfile C:\AWSCLIV2.msi
        $arguments = "/i `"C:\AWSCLIV2.msi`" /quiet"
        Start-Process msiexec.exe -ArgumentList $arguments -Wait    
}
prereq
sleep 240
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
$password2 = $(aws secretsmanager get-secret-value --secret-id password_windows --region us-east-1 | ConvertTo-SecureString -AsPlainText -Force)
new-localuser -name "localadmin2" -password $password2
add-localgroupmember -group "Remote Desktop Users" -member "localadmin2"
add-localgroupmember -group "Administrators" -member "localadmin2"
</powershell>
