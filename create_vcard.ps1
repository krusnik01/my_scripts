Start-Transcript -Path C:\scripts\create_vcard.txt

Remove-Item "D:\Share\it\vcard.vcf"

Import-Module ActiveDirectory

$vCardPath = "D:\Share\it\vcard.vcf"
#test to see if vcard file already exists
$outputvcard = Test-Path $vCardPath 
If (!$outputvcard){
 #if not then create the file
 $outputvcard = New-Item -Path $vCardPath -ItemType File -Force
}
#get AD users
$ADUsers = Get-ADObject -SearchBase "DC=bionlab,DC=local" -Filter {(ObjectClass -eq "User") -or (ObjectClass -eq "contact") } -Properties * | Select givenName,SN,Mail,Mobile,OfficePhone,ipPhone,initials | Sort-Object SN

ForEach ($user in $ADUsers){ 
 if ($user.ipPhone.Length -lt 1){
 continue 
 }
 Add-Content -Encoding UTF8 -Path $vCardPath -Value "BEGIN:VCARD"
 Add-Content -Encoding UTF8 -Path $vCardPath -Value "VERSION:2.1"
 if (($user.initials.Length -lt 1) -and($user.givenName -ne $null)){
  $user.initials =$user.givenName.Chars(0)
  }
 Add-Content -Encoding UTF8 -Path $vCardPath -Value "N:$($user.SN);$($user.initials)"
 if ($user.mobile.Length -ge 1){
 Add-Content -Path $vCardPath -Value "TEL;HOME:$($user.mobile)"
 }
 Add-Content -Encoding UTF8 -Path $vCardPath -Value "TEL;WORK:$($user.ipPhone)"
 Add-Content -Encoding UTF8 -Path $vCardPath -Value "END:VCARD"
 Add-Content -Encoding UTF8 -Path $vCardPath -Value ""
}

Stop-Transcript