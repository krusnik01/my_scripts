Start-Transcript -Path C:\scripts\update_po.txt
Remove-item C:\Soft\bitrix24_desktop.msi
Invoke-WebRequest "https://dl.bitrix24.com/b24/bitrix24_desktop.msi" -OutFile "C:\Soft\bitrix24_desktop.msi"
Remove-item C:\Soft\firefox.msi
Invoke-WebRequest "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=ru" -OutFile "C:\Soft\firefox.msi"
Remove-item C:\Soft\Thunderbird.msi
Invoke-WebRequest "https://download.mozilla.org/?product=thunderbird-msi-latest-ssl&os=win64&lang=ru" -OutFile "C:\Soft\Thunderbird.msi"
Stop-Transcript