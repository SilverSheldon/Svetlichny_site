# Конфигурация Gunicorn для production
import os
import multiprocessing

# Количество worker процессов (обычно 2-4 * количество CPU)
workers = int(os.environ.get('GUNICORN_WORKERS', multiprocessing.cpu_count() * 2 + 1))

# Адрес и порт
bind = f"0.0.0.0:{os.environ.get('PORT', 6000)}"

# Тип worker
worker_class = "sync"

# Таймауты
timeout = 120
keepalive = 5

# Логирование
accesslog = "-"  # stdout
errorlog = "-"   # stderr
loglevel = os.environ.get('LOG_LEVEL', 'info').lower()

# Перезапуск worker'ов после обработки этого количества запросов
max_requests = 1000
max_requests_jitter = 50

# Имя приложения
proc_name = "infobez"

# Предварительная загрузка приложения для экономии памяти
preload_app = True

# Пользователь для запуска (будет установлен в Dockerfile)
# user = "appuser"
# group = "appuser"

