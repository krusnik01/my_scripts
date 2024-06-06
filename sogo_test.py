import sys

import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import time

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
con = 0


def get_request(user):
    global con
    con += 1
    sys.stdout.write(f'\ractive_users {str(con)}')
    sys.stdout.flush()
    base_url = f'https://{hostName}/SOGo/'
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:104.0) Gecko/20100101 Firefox/104.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
        'Accept-Encoding': 'gzip, deflate, br'
    }
    data = {
        'userName': f"{user}@{domen}",
        'password': password,
        'domain': 'null',
        'rememberLogin': 0
    }

    with requests.Session() as session:
        session = requests.Session()
        session.headers.update(headers)
        response = session.get(f'{base_url}so/', verify=False)
        response = session.post(f'{base_url}connect/', json=data, verify=False)
        cook_id = session.cookies.get_dict()
        my_cookie = requests.cookies.create_cookie('session',
                                                   'eyJjc3JmX3Rva2VuIjoiMTYyYTBkYzBhMTQ4OTdlNDg3MWZlOWUyODlkMTdlNGYwZTY4YTkxNSJ9.ZC0Wmw.i413pd6gSNiwq53-P_edfLh77kk')
        for k in cook_id.keys():
            if "XSRF-TOKEN" in k:
                session.headers.update({'X-XSRF-TOKEN': cook_id[k]})
        response = session.get(f'{base_url}so/{user}@{domen}', verify=False)
        indata = {'sortingAttributes': {'asc': 0, 'sort': 'arrival'}}
        response = session.post(f'{base_url}so/{user}@{domen}/Mail/0/folderINBOX/view', json=indata, verify=False)

        for i in range(int(test_min * 60 / idle_time)):
            response = session.get(f'{base_url}so/{user}@{domen}', verify=False)
            indata = {'sortingAttributes': {'asc': 0, 'sort': 'arrival'}}
            response = session.post(f'{base_url}so/{user}@{domen}/Mail/0/folderINBOX/view', json=indata, verify=False)
            time.sleep(idle_time)
        session.close()
    con -= 1
    sys.stdout.write(f'\ractive_users {str(con)}')
    sys.stdout.flush()

if __name__ == "__main__":
    domen = ''                                # почтовый домен
    hostName = ''                         # адрес балансира
    password = "3"                             # пароль УЗ
    idle_time = 15                                     # sleep time секунды
    test_min = 10                                      # время действия в минутах в одном ящики  
    thread_count = 1000                                # количество потоков
    sys.stdout.write('start\n')
    users = []
    with open('accs', mode='r') as f1:
        for line in f1.readlines():
            users.append(line.strip())

    from concurrent.futures import ThreadPoolExecutor

    with ThreadPoolExecutor(thread_count) as executor:
        results = executor.map(get_request, users)
