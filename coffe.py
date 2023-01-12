#!/usr/bin/env python3
from datetime import datetime
from requests import get

#Проверка выходного
if datetime.now().weekday() in [5,6]:
    exit(0)

D1={'User1':00000, 'User2':00000, 'User3':000000, 'User4':0000000 } #id телеги
D2={0:'User1',1:'User2',2:'User3',3:'User4'}                                        #очередь

def read_file():
    file_iter_day = open('iter_day.txt', 'r')                                   #читаем файл
    if (len(file_iter_day.read()))!=0:                                          #проверяем что не пустой
        file_iter_day.seek(0, 0)
        iter_day=int(file_iter_day.read())                                      #получаем № очереди
    else:
        file_iter_day = open('iter_day.txt', 'w')                               #если пустой то создаём и начинаем с 0
        file_iter_day.write('0')
        iter_day=0
    file_iter_day.close()
    return iter_day

iter_day=read_file()

#готовимся к отправке сообщения

abonent=D2[iter_day]
chat_id=D1[abonent]                                                           #получаем чат ид
text_message=f'{abonent}! Сегодня ты! Моешь кофеварку.'   #формируем текст сообщения

get("api_telegram" + f"/sendMessage?chat_id={chat_id}&text={text_message}") #отправляем
get("api_telegram" + f"/sendMessage?chat_id=323408164&text=Я сделял") #отчитываемся

def log(abonent):

    file_log=open('coffe.log' , 'a+')                                           #создаём лог файл
    now = datetime.now().strftime("%d %m %Y в %H:%M")                           #получаем дату
    file_log.write(f'Бот запущен {now} Сообщение отправлено абоненту {abonent} \n')  # записываем в файл
    file_log.close()                                                            #закрываем

log(abonent)

# перемещаем очередь
if iter_day==2:
    iter_day=0
else:
    iter_day+=1

#записываем в файл новое значение очереди
def write_file(iter_day):
    s1=str(iter_day)
    file_iter_day = open('iter_day.txt', 'w')
    file_iter_day.write(s1)
    file_iter_day.close()

write_file(iter_day)

