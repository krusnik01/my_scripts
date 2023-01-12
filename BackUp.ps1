$path_daily = "C:\Logs\Log_daily.txt"
$path_week = "C:\Logs\Log_week.txt"
$path_month = "C:\Logs\Log_month.txt"
$path_year = "C:\Logs\Log_year.txt"
robocopy B:\bak D:\bak /E /PURGE /UNILOG:$path_daily
robocopy B:\week D:\week /E /PURGE /UNILOG:$path_week
robocopy B:\mounth D:\mounth /E /PURGE /UNILOG:$path_month
robocopy B:\year D:\year /E /PURGE /UNILOG:$path_year
