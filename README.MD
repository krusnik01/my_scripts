#BackUp.ps1
Копия бекапов в другое место

#bitrix&mikrot
Вебхуком забираем сообщение от чат бота, генерируем логин пароль для VPN на микротике с ограниченим по времени доступа

#clear.ps1
Чистим файлы старше N дней

#coffe.py
Скрипт очередности кто моет кофеварку) 

#count.sh
Парсим лог для заббикса

#create_vcard.ps1
Создаёт карточку контактов для ip телефонов (которые не умею сами к АД подключаться)

#rtsp_cam.py
Скрипт подключаетсяч к камере, кропает картинку и сравивает её с стоковой (которую надо подготовить) при больших расхождениях отправляет сообщение в телеграмм.
  #Собираем билд
  docker build -t rtsp_cam .

  #запускаем и монтируем папку лога
  docker run -d -v /home/user/rtsp_cam/log/:/root/cam/log rtsp_cam
  
#sendmail.ps1
Просто отсылка письма через ps

#shutdowns
Перезагружаем PC из внешнего файла

#update_po.ps1
Загружаем свежие версии ПО

#imap&smtp_test.py
Нагрузочное тестирование imap и smtp протоколов

#search.sh
Сбор логов с серверов VK WorkMail

#sogo_test.py
Нагрузочное тестирование web клиента SOGO
