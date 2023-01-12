for /F %%x in (complist.txt) do shutdown.exe /r /f /m \\%%x /t 21600
msg * "done"

