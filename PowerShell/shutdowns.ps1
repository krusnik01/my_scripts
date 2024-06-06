for (%x in (`complist.txt`)){
	shutdown.exe /r /t 3 /s \\%x /f
}