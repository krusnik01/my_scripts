
# Скрипт для поиска и выгрузки логов с серверов

# Параметры по умолчанию
#DEFAULT_NAME_LOG="logs_$(date +%Y%m%d)"
#DEFAULT_START_TIME="$(date -d '1 hour ago' +'%Y-%m-%dT%H:%M')"
#DEFAULT_END_TIME="$(date +'%Y-%m-%dT%H:%M')"
DEFAULT_OUTPUT_DIR="/tmp"
DEFAULT_SSH_KEY="/home/USER01/.ssh/id_rsa"
DEFAULT_SERVICE_LIST="service.list"
DEFAULT_SERVER_LIST="all.list"
DEFAULT_LOG_FILE="script.log"
DEFAULT_MAX_THREADS=1

# Функция для вывода справки
usage() {
    echo "Использование: $0 -n <name_log> -s <start_time> -e <end_time> [OPTIONS]"
    echo
    echo "Обязательные параметры:"
    echo "  -n, --name-log       Имя директории для сохранения логов(номер кейса)"
    echo "  -s, --start-time     Время начала поиска (формат: YYYY-MM-DDThh:mm пример 2025-03-29T17:00)"
    echo "  -e, --end-time       Время окончания поиска (формат: YYYY-MM-DDThh:mm пример 2025-03-31T17:00)"
    echo
    echo "Дополнительные параметры:"
    echo "  -o, --output-dir     Директория для сохранения результатов (по умолчанию: $DEFAULT_OUTPUT_DIR)"
    echo "  -k, --ssh-key        Путь до SSH ключа (по умолчанию: $DEFAULT_SSH_KEY)"
    echo "  -z, --zip            Заархивировать выгруженные логи в общий архив .tar.gz"
    echo "  -l, --service-list   Файл со списком сервисов (по умолчанию: $DEFAULT_SERVICE_LIST)"
    echo "  -a, --server-list    Файл со списком серверов (по умолчанию: $DEFAULT_SERVER_LIST)"
    echo "  -f, --log-file       Файл для логов скрипта (по умолчанию: $DEFAULT_LOG_FILE)"
    echo "  -t, --threads        Максимальное количество потоков (по умолчанию: $DEFAULT_MAX_THREADS)"
    echo "  -h, --help           Показать эту справку"
    echo
    echo "Пример:"
    echo "  $0 -n my_logs -s '2025-03-31T17:00' -e '2025-03-31T18:00' -z -t 5"
    exit 1
}

# Проверка наличия обязательных параметров
check_required_params() {
    if [ -z "$name_log" ] || [ -z "$start_time" ] || [ -z "$end_time" ]; then
        echo "Ошибка: отсутствуют обязательные параметры!"
        usage
    fi
}

# Парсинг аргументов командной строки
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--name-log) name_log="$2"; shift ;;
        -s|--start-time) start_time="$2"; shift ;;
        -e|--end-time) end_time="$2"; shift ;;
        -o|--output-dir) output_dir="$2"; shift ;;
        -k|--ssh-key) ssh_key="$2"; shift ;;
        -z|--zip) archive_logs=true ;;
        -l|--service-list) service_list="$2"; shift ;;
        -a|--server-list) server_list="$2"; shift ;;
        -f|--log-file) log_file="$2"; shift ;;
        -t|--threads) max_threads="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Неизвестный параметр: $1"; usage ;;
    esac
    shift
done

# Установка значений по умолчанию для необязательных параметров
name_log=${name_log:-$DEFAULT_NAME_LOG}
start_time=${start_time:-$DEFAULT_START_TIME}
end_time=${end_time:-$DEFAULT_END_TIME}
output_dir=${output_dir:-$DEFAULT_OUTPUT_DIR}
ssh_key=${ssh_key:-$DEFAULT_SSH_KEY}
service_list=${service_list:-$DEFAULT_SERVICE_LIST}
server_list=${server_list:-$DEFAULT_SERVER_LIST}
log_file=${log_file:-$DEFAULT_LOG_FILE}
max_threads=${max_threads:-$DEFAULT_MAX_THREADS}
archive_logs=${archive_logs:-false}

# Проверка обязательных параметров
check_required_params

# Полный путь к директории с логами
output_dir="${output_dir}/${name_log}"

# Вычисляем end_date для поиска
end_date=$(date -d "${end_time%%T*} +1 day" +%Y-%m-%d)

# Генерация уникального ID
generate_unique_id() {
    date +"%Y%m%d_%H%M%S_%S"
}

# Проверка существования файлов со списками
if [ ! -f "$service_list" ]; then
    echo "Ошибка: файл со списком сервисов '$service_list' не найден."
    exit 1
fi

if [ ! -f "$server_list" ]; then
    echo "Ошибка: файл со списком серверов '$server_list' не найден."
    exit 1
fi

# Проверка и создание директории для сохранения логов
if [ ! -d "$output_dir" ]; then
    echo "Директория $output_dir не существует, создаю..."
    mkdir -p "$output_dir"
    if [ $? -ne 0 ]; then
        echo "Ошибка: не удалось создать директорию $output_dir."
        exit 1
    fi
    echo "Директория $output_dir успешно создана."
fi

echo "Лог скрипта пишется в файл $log_file"

echo "===== Начало работы скрипта: $(date +"%Y-%m-%d %H:%M:%S") =====" >> "$log_file"

# Основной цикл
server_count=$(wc -l < "$server_list")
current_server=0

# Функция для обработки одного сервера
process_server() {
    local srv=$1
    local srv_name=$(echo $srv | sed 's/^p0mail-//')

    for service_name in $(cat "$service_list"); do
        files=$(ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i $ssh_key USER01@$srv "
            sudo find /var/log/workmail/$srv_name/ -type f -name '$service_name*' -newermt '${start_time%%T*}' ! -newermt '$end_date' 2>/dev/null
        ")

        if [ -n "$files" ]; then
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] Найдены файлы для сервиса $service_name на сервере $srv" >> "$log_file"
            for file in $files; do
                log_name=$(basename "$file")
                unique_id=$(generate_unique_id)
                output_file="${output_dir}/${srv_name}_${log_name}_${unique_id}.log"

                # Выгружаем и фильтруем логи
                if [[ "$file" == *.gz ]]; then
                    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i $ssh_key USER01@$srv "sudo zcat \"$file\"" | awk "\$1 >= \"$start_time\" && \$1 <= \"$end_time\"" > "$output_file"
                elif [[ "$file" == *.log ]]; then
                    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i $ssh_key USER01@$srv "sudo cat \"$file\"" | awk "\$1 >= \"$start_time\" && \$1 <= \"$end_time\"" > "$output_file"
                fi

                if [ ! -s "$output_file" ]; then
                    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Файл $output_file пустой после фильтрации, удаляю..." >> "$log_file"
                    rm -f "$output_file"
                else
                    # Сжимаем файл в .gz и удаляем исходник
                    gzip "$output_file"
                    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Логи сохранены и сжаты: ${output_file}.gz" >> "$log_file"
                fi
            done
        fi
    done
}

# Обработка серверов с ограничением на количество потоков
for srv in $(cat "$server_list"); do
    current_server=$((current_server + 1))
    printf "\rПоиск на сервере %d из %d" "$current_server" "$server_count"
    echo "Начал поиск на сервере $srv"  >> "$log_file"
    # Запуск обработки сервера в фоновом режиме
    process_server "$srv" &
    echo "Закончил поиск на сервере $srv"  >> "$log_file"
    # Ограничение количества одновременно выполняющихся процессов
    if [[ $(jobs -r -p | wc -l) -ge $max_threads ]]; then
        wait -n
    fi
done

# Ожидаем завершения всех оставшихся процессов
wait

# Создание общего архива, если указан флаг -z
if $archive_logs; then
    archive_name="${output_dir}/${name_log}.tar"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Архивирую логи в $archive_name.gz ..." >> "$log_file"
    tar -cf "$archive_name" -C "$output_dir" .
    gzip "$archive_name"
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] Архивация завершена: ${archive_name}.gz" >> "$log_file"
fi									  
echo "===== Завершение работы скрипта: $(date +"%Y-%m-%d %H:%M:%S") =====" >> "$log_file"
echo "Готово! Результаты сохранены в: $output_dir"
