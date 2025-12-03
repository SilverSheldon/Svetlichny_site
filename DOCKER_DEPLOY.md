# Документация по деплою через Docker

## Описание проекта

Svetlichny Site - веб-приложение на Flask для публикации статей по информационной безопасности. Приложение использует SQLite для хранения данных и Gunicorn в качестве WSGI-сервера для production.

## Требования

- Docker (версия 20.10 или выше)
- Docker Compose (версия 1.29 или выше)
- Доступ к серверу с IP-адресом 45.8.99.227

## Структура проекта

```
.
├── app.py                 # Основное Flask приложение
├── gunicorn_config.py     # Конфигурация Gunicorn
├── requirements.txt       # Python зависимости
├── Dockerfile             # Docker образ для production
├── docker-compose.yml     # Docker Compose конфигурация
├── .env.production        # Пример переменных окружения для production
├── .dockerignore          # Файлы, исключаемые из Docker образа
├── deploy.sh              # Скрипт автоматического деплоя
├── data/                  # Директория для базы данных (монтируется как volume)
├── ssl/                   # Директория для SSL сертификатов (опционально)
├── static/                # Статические файлы (CSS, JS, изображения)
└── templates/             # HTML шаблоны
```

## Быстрый старт

### 1. Подготовка сервера

Убедитесь, что на сервере установлены Docker и Docker Compose:

```bash
# Проверка версии Docker
docker --version

# Проверка версии Docker Compose
docker-compose --version
```

Если Docker не установлен, установите его согласно [официальной документации](https://docs.docker.com/engine/install/).

### 2. Клонирование проекта

```bash
# Клонируйте репозиторий на сервер
git clone <repository-url>
cd Svetlichny_site
```

### 3. Настройка переменных окружения

Создайте файл `.env` на основе `.env.production`:

```bash
cp .env.production .env
```

Отредактируйте `.env` файл и установите безопасные значения:

```env
# Обязательно измените эти значения!
SECRET_KEY=your-very-secure-random-secret-key-here
ADMIN_PASSWORD=your-strong-admin-password-here

# Остальные настройки можно оставить по умолчанию
FLASK_ENV=production
FLASK_DEBUG=False
HOST=0.0.0.0
PORT=6000
DATABASE_PATH=/app/data/articles.db
SERVER_NAME=45.8.99.227
PREFERRED_URL_SCHEME=http
SSL_ENABLED=false
GUNICORN_WORKERS=4
LOG_LEVEL=info
```

**Важно:** 
- `SECRET_KEY` должен быть длинным случайным строковым значением (минимум 32 символа)
- `ADMIN_PASSWORD` должен быть надежным паролем для доступа к админ-панели
- Для генерации SECRET_KEY можно использовать: `python -c "import secrets; print(secrets.token_hex(32))"`

### 4. Создание необходимых директорий

```bash
mkdir -p data ssl
```

Директория `data/` будет использоваться для хранения базы данных SQLite (монтируется как volume, чтобы данные сохранялись при перезапуске контейнера).

### 5. Деплой приложения

#### Вариант 1: Использование скрипта деплоя

```bash
# Сделайте скрипт исполняемым
chmod +x deploy.sh

# Запустите деплой
./deploy.sh
```

#### Вариант 2: Ручной деплой

```bash
# Сборка образа
docker-compose build

# Запуск контейнера
docker-compose up -d

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

### 6. Проверка работы

После успешного деплоя приложение будет доступно по адресу:
- **HTTP:** http://45.8.99.227:6000
- **Админ-панель:** http://45.8.99.227:6000/admin

## Управление контейнером

### Просмотр логов

```bash
# Все логи
docker-compose logs

# Логи в реальном времени
docker-compose logs -f

# Последние 100 строк
docker-compose logs --tail=100
```

### Остановка и запуск

```bash
# Остановка контейнера
docker-compose stop

# Запуск контейнера
docker-compose start

# Перезапуск контейнера
docker-compose restart
```

### Обновление приложения

```bash
# Остановка контейнера
docker-compose down

# Получение последних изменений из Git
git pull

# Пересборка образа
docker-compose build --no-cache

# Запуск обновленного контейнера
docker-compose up -d
```

### Полная остановка и удаление

```bash
# Остановка и удаление контейнера
docker-compose down

# Удаление также volumes (ОСТОРОЖНО: удалит базу данных!)
docker-compose down -v
```

## Настройка HTTPS (опционально)

Если вы хотите использовать HTTPS, выполните следующие шаги:

### 1. Получение SSL сертификатов

Поместите ваши SSL сертификаты в директорию `ssl/`:
- `ssl/cert.pem` - сертификат
- `ssl/key.pem` - приватный ключ

### 2. Обновление .env файла

```env
SSL_ENABLED=true
SSL_CERT_PATH=ssl/cert.pem
SSL_KEY_PATH=ssl/key.pem
PREFERRED_URL_SCHEME=https
```

### 3. Настройка портов в docker-compose.yml

Если используете HTTPS, убедитесь, что порт 443 открыт и правильно настроен в `docker-compose.yml`.

### 4. Перезапуск контейнера

```bash
docker-compose down
docker-compose up -d
```

## Настройка Nginx как reverse proxy (рекомендуется)

Для production рекомендуется использовать Nginx как reverse proxy перед приложением:

### Пример конфигурации Nginx

```nginx
server {
    listen 80;
    server_name 45.8.99.227;

    location / {
        proxy_pass http://localhost:6000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Мониторинг и обслуживание

### Проверка использования ресурсов

```bash
# Использование ресурсов контейнером
docker stats svetlichny_site

# Информация о контейнере
docker inspect svetlichny_site
```

### Резервное копирование базы данных

```bash
# Создание резервной копии
docker exec svetlichny_site cp /app/data/articles.db /app/data/articles.db.backup

# Или копирование с сервера
docker cp svetlichny_site:/app/data/articles.db ./backup/articles.db.$(date +%Y%m%d_%H%M%S)
```

### Восстановление базы данных

```bash
# Копирование файла базы данных в контейнер
docker cp ./backup/articles.db svetlichny_site:/app/data/articles.db

# Перезапуск контейнера
docker-compose restart
```

## Устранение неполадок

### Контейнер не запускается

1. Проверьте логи: `docker-compose logs`
2. Убедитесь, что порт 6000 не занят: `netstat -tuln | grep 6000`
3. Проверьте права доступа к директориям `data/` и `ssl/`

### Приложение недоступно

1. Проверьте, что контейнер запущен: `docker-compose ps`
2. Проверьте firewall на сервере: `sudo ufw status`
3. Убедитесь, что порт 6000 открыт: `sudo ufw allow 6000/tcp`

### Проблемы с базой данных

1. Проверьте права доступа к файлу БД: `ls -la data/articles.db`
2. Убедитесь, что директория `data/` монтируется правильно
3. Проверьте логи приложения на ошибки БД

### Проблемы с SSL

1. Убедитесь, что сертификаты находятся в `ssl/` директории
2. Проверьте права доступа к сертификатам: `ls -la ssl/`
3. Убедитесь, что `SSL_ENABLED=true` в `.env` файле

## Безопасность

### Рекомендации по безопасности

1. **Всегда меняйте SECRET_KEY и ADMIN_PASSWORD** в production
2. Используйте сильные пароли для админ-панели
3. Настройте firewall для ограничения доступа
4. Регулярно обновляйте Docker образы и зависимости
5. Используйте HTTPS в production (через Nginx или встроенный SSL)
6. Не коммитьте `.env` файл в Git
7. Регулярно создавайте резервные копии базы данных

### Проверка безопасности

```bash
# Проверка уязвимостей в зависимостях
docker run --rm -v $(pwd):/app python:3.11-slim bash -c "cd /app && pip install safety && safety check"

# Обновление зависимостей
docker-compose exec web pip list --outdated
```

## Производительность

### Настройка Gunicorn workers

Количество worker процессов можно настроить через переменную окружения `GUNICORN_WORKERS`:

```env
# Рекомендуется: (2 * CPU cores) + 1
GUNICORN_WORKERS=4
```

### Мониторинг производительности

```bash
# Использование ресурсов
docker stats svetlichny_site

# Логи с уровнем debug (для отладки)
# В .env установите: LOG_LEVEL=debug
```

## Контакты и поддержка

При возникновении проблем проверьте:
1. Логи контейнера: `docker-compose logs`
2. Статус контейнера: `docker-compose ps`
3. Документацию Docker: https://docs.docker.com/

---

**Последнее обновление:** 2024

