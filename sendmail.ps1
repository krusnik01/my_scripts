$User = '' #тут логин почты
$PWord = ConvertTo-SecureString -String 'password' -AsPlainText -Force #пароль
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$MailMessage = @{
To = ''  
From = ''
Subject = 'Test mail'
Body = '<html><h1>ТЕСТ</h1> <p><strong>-сформировано:</strong> $(Get-Date -Format g)</p></html>'
Smtpserver = 'smtp.mail.ru'
Port = 25
UseSsl = $false
BodyAsHtml = $true
Encoding = 'UTF8'
}
Send-MailMessage @MailMessage -Credential $cred
