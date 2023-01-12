#бот на сообщение в битриксе берёт логин пользователя, создаёт или обновляет такого же в микротике, создаёт скрипт который через t времени выключит этого пользователя

import datetime
import random
import subprocess
import re

    


vpn_user="$user+test" #id пользователя получаем из битрикса, по нему будем искать в микроте


api_key="" #ключ битрикса
webhook_request="" #тело запроса
'''
def get_msg():
Здесь магия получения сообщения 
Итогом становиться id пользователя и чат с ним

'''









vpn_user="vsheremet"

###########################
# Mikrotik
###########################

#генерим пароль и юзера
def gen_user_pass():
    vpn_pass=""
    temp_vpn="" #временный логин vpn и имя скрипта для удаления
    charsPASS = '+-/*!&$#?=@<>abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    charsUSER = 'abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    for n in range(9):
        vpn_pass+= random.choice(charsPASS)
        temp_vpn+= random.choice(charsUSER)
    return(vpn_user,vpn_pass)
    
#делаем время для микрота
def gen_end_time():
    h=3 # время жизни пароля (часы)
    m=0 # время жизни пароля (минуты)
    now_hours= int(datetime.datetime.now().strftime("%H"))+h
    if now_hours>=24 :
        now_hours=int(now_hours%24+now_hours/24-1)
    now_min=int(datetime.datetime.now().strftime("%M"))+m
    if now_min>=60:
        now_min=int(now_min%60+now_min/60-1)
    now_time=(f'{now_hours}:{now_min}:00')
    return(now_time)

#Подключение по ssh и отправка запроса, возращает значение
def send_request(mikrot_request):
    ip_mikrot="10.2.1.251" #ip адрес микрота
    ssh_user="vpn_bot" #логин микротика
    ssl_key="\"C:\\Users\\vsheremet\\.ssh\\vpn_bot_priv\""
    command= f"ssh {ssh_user}@{ip_mikrot} -i {ssl_key} {mikrot_request}"
    return(str(subprocess.run(command, stdout=subprocess.PIPE).stdout))


#Получаем исходный caller_id
get_caller_id=f"ppp secret print value-list where name={vpn_user}"
caller_id=send_request(get_caller_id)
caller_id=re.sub('[^.0-9]','', caller_id[caller_id.find("caller-id:"):caller_id.find("password")])

#Убираем ограничение
set_vpn=f'ppp secret set [find where name={vpn_user}] caller-id=0.0.0.0'
send_request(set_vpn)

#Создаём скрипт возрата caller_id
set_scheduler=f'system scheduler add name={vpn_user} start-time={gen_end_time()} on-event={{ppp secret set vsheremet caller-id={caller_id} ; system scheduler remove {vpn_user}; ppp active remove [find where name={vpn_user}]}}'
send_request(set_scheduler)