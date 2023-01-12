#! /bin/bash
today=$(date +"%b %e")
path=/var/log/postfix/mail.log
savePath=/home/bionadmin/resGrep.txt

grep "$today" $path > $savePath
grep -c "sent" $savePath > /home/bionadmin/count.txt
rm $savePath
