Start-Transcript -Path C:\scripts\clear_email.txt
$password = 'Password'
$username = 'User'
New-SmbMapping -Username $username -Password $password `
    -LocalPath 'L:' -RemotePath '\\10.2.1.5\Shares\EMail\отправленные результаты' `
    -Persistent $true
$date = (Get-Date).AddDays(-90)
$path = "L:\"
Get-ChildItem -File -Recurse -Path $path | Where-Object -Property LastWriteTime -LT $date | Remove-Item
Stop-Transcript