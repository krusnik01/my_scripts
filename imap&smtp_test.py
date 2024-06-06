import binascii
import random
import string
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
import imaplib
import email
import base64
from logging import getLogger, basicConfig, DEBUG, INFO, ERROR
from random import choice
import time

post_server = ''  # Адрес сервера
accs_file = r""  # Путь к файлу со списком юзеров, для экранирования впереди ставь r
post_pass = ''  # Пароль для юзеров
domen = ''  # Домен
test_time = 60  # Время теста в секундах
thread_count = 10  # Кол-во процессов теста
lvl_logs = DEBUG  # DEBUG, INFO, ERROR


def imap_search(msg_array, imap, compare_sender):
    compare_body = choice(msg_array)
    result = False
    try:
        imap.select("INBOX")
        uid_array = (imap.uid('search', "ALL"))[1][0].decode().split(' ')
        for uid in uid_array:
            msg_imap = imap.uid('fetch', uid, '(RFC822)')[1]
            msg_imap = email.message_from_bytes(msg_imap[0][1])
            # Отправитель
            msg_recever = msg_imap["Return-path"].replace('<', '').replace('>', '')
            if msg_recever != compare_sender: continue
            # Тело письма
            msg_body = ''
            for part in msg_imap.walk():
                if part.get_content_maintype() == 'text' and part.get_content_subtype() == 'plain':
                    try:
                        msg_body = (base64.b64decode(part.get_payload()).decode())
                    except binascii.Error as err:
                        msg_body = part.get_payload()
                    except UnicodeDecodeError as err:
                        msg_body = part.get_payload()
            if msg_body == compare_body and msg_recever == compare_sender:
                result = True
                break
    except imaplib.IMAP4.error as err:
        logger.error(err)
    finally:
        return result


def imap_dir(imap_server):
    status, folders = imap_server.list()
    if status == 'OK':
        folders = [key.decode().split('"/"')[-1].strip() for key in folders]
    else:
        logger.error(f'ERROR {status}')
        return False
    for folder in folders:
        pass
        logger.debug(f'\t{folder} select - {(imap_server.select(folder))}', )
    return True


def smtp_send(login):
    try:
        with smtplib.SMTP_SSL(post_server, 465, timeout=20) as smtp_srv:
            # smtp_srv = smtplib.SMTP('localhost', port=25, timeout=5)
            smtp_srv.login(login, post_pass)
            # генерация сообщения
            # Создание объекта сообщения
            msg_to_send = MIMEMultipart()
            # Генерим уникальный текст
            message_text = ''.join(random.choice(string.ascii_letters + ' ') for _ in range(100))
            # Настройка параметров сообщения
            msg_to_send["From"] = login
            msg_to_send["To"] = login
            msg_to_send["Subject"] = "Monitoring test message"
            msg_to_send.attach(MIMEText(message_text, "plain"))
            # Отправка письма
            smtp_srv.sendmail(login, login, msg_to_send.as_string())
            smtp_srv.quit()
            return message_text
    except TimeoutError:
        logger.error('TimeoutError')
    except ConnectionRefusedError:
        logger.error('ConnectionRefusedError')
    except smtplib.SMTPAuthenticationError as err:
        logger.error(err.__dict__['smtp_error'].decode())
    return False


def del_email(imap_server):
    logger.debug(f'\t{imap_server.select("INBOX")}')
    uid_array = (imap_server.uid('search', "ALL"))[1][0].decode().split(' ')
    imap_server.uid('store', choice(uid_array), '+flags \\Deleted')
    imap_server.expunge()


def treading(post_user):

    logger.info(f'Processing account {post_user}@{domen}')
    messages = []
    try:
        with imaplib.IMAP4_SSL(post_server, timeout=30) as imap_server:
            try:
                imap_server.login(user=f'{post_user}@{domen}', password=post_pass)
            except imaplib.IMAP4.error as err:
                logger.error(err)
                return
            while time.perf_counter() - start < test_time:
                task_id = choice(['Щелкаем папки', 'Отправка письма', 'Поиск письма', 'Удаление письма'])
                logger.info(f'Task : {task_id}')
                if task_id == 'Щелкаем папки':
                    if not imap_dir(imap_server):
                        return False
                elif task_id == 'Поиск письма':
                    if len(messages) == 0:
                        res = smtp_send(f'{post_user}@{domen}')
                        logger.debug(f'\t{res}')
                        if res:
                            messages.append(res)
                    imap_search_res = imap_search(messages, imap_server, f'{post_user}@{domen}')
                    logger.debug(f'\t{imap_search_res}')
                elif task_id == 'Отправка письма':
                    res = smtp_send(f'{post_user}@{domen}')
                    logger.debug(f'\t{res}')
                    if res != False:
                        messages.append(res)
                elif task_id == 'Удаление письма':
                    del_email(imap_server)
                time.sleep(0.5)
    except TimeoutError:
        logger.error('TimeoutError')


if __name__ == '__main__':
    logger = getLogger()
    FORMAT = '%(asctime)s: %(name)s : %(levelname)s : %(message)s'
    basicConfig(level=lvl_logs, format=FORMAT)  # , filename="py_log.log", filemode="w")
    users = []
    with open(accs_file, mode='r') as f1:
        for line in f1.readlines():
            users.append(line.strip())
    start = time.perf_counter()
    start_time = datetime.now()
    try:
        from concurrent.futures import ThreadPoolExecutor

        with ThreadPoolExecutor(thread_count) as executor:
            results = executor.map(treading, users)
    except KeyboardInterrupt:
        pass
    logger.info(f'Job seconds {(datetime.now() - start_time).seconds}')
