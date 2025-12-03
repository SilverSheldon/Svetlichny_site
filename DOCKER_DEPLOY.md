# Деплой приложения в Docker

Это руководство описывает процесс деплоя приложения на удаленный сервер с использованием Docker.

## Предварительные требования

- Docker (версия 20.10+)
- Docker Compose (версия 2.0+)
- Доступ к удаленному серверу (SSH)
- Доменное имя (опционально, но рекомендуется)

## Локальная сборка и тестирование

### 1. Подготовка окружения

```bash
# Клонируйте репозиторий (или скопируйте файлы на сервер)
git clone <your-repo>
cd test_site

# Создайте директории для данных
mkdir -p data ssl
```

### 2. Создайте файл с переменными окружения

```bash
cp .env.example .env
# Отредактируйте .env и задайте необходимые значения
nano .env
```

**Важно изменить:**
- `SECRET_KEY` - сгенерируйте случайную строку
- `ADMIN_PASSWORD` - установите надежный пароль
- `SERVER_NAME` - укажите ваш домен

### 3. Сборка Docker образа

```bash
docker build -t infobez:latest .
```

### 4. Запуск с Docker Compose

```bash
docker-compose up -d
```

Проверьте, что контейнер запущен:
```bash
docker-compose ps
docker-compose logs -f
```

Приложение будет доступно на `http://localhost:5000`

## Деплой на удаленный сервер

### Вариант 1: Простой деплой (docker-compose)

#### 1. Подключитесь к серверу

```bash
ssh user@your-server.com
```

#### 2. Установите Docker и Docker Compose

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**CentOS/RHEL:**
```bash
sudo yum install -y docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

#### 3. Загрузите файлы на сервер

```bash
# С вашего локального компьютера
scp -r . user@your-server.com:/opt/infobez/
```

Или используйте Git:
```bash
# На сервере
git clone <your-repo> /opt/infobez
cd /opt/infobez
```

#### 4. Настройте переменные окружения

```bash
cd /opt/infobez
cp .env.example .env
nano .env  # Отредактируйте значения
```

#### 5. Создайте необходимые директории

```bash
mkdir -p data ssl
chmod 755 data ssl
```

#### 6. Запустите приложение

```bash
docker-compose build
docker-compose up -d
```

#### 7. Проверьте статус

```bash
docker-compose ps
docker-compose logs -f web
```

### Вариант 2: С использованием Nginx Reverse Proxy

Для production рекомендуется использовать Nginx в качестве reverse proxy.

#### 1. Создайте конфигурацию Nginx

`/etc/nginx/sites-available/infobez`:
```nginx
server {
    listen 80;
    server_name infobez your-domain.com;

    # Перенаправление HTTP на HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name infobez your-domain.com;

    ssl_certificate /path/to/ssl/cert.pem;
    ssl_certificate_key /path/to/ssl/key.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    client_max_body_size 10M;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
}
```

#### 2. Активируйте конфигурацию

```bash
sudo ln -s /etc/nginx/sites-available/infobez /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 3. Обновите docker-compose.yml

Измените порты:
```yaml
ports:
  - "127.0.0.1:5000:5000"  # Только локальный доступ
```

### Вариант 3: Использование Gunicorn (Production)

Для production рекомендуется использовать Gunicorn вместо встроенного сервера Flask.

#### 1. Обновите Dockerfile

```dockerfile
# В конце Dockerfile замените CMD на:
CMD ["gunicorn", "--config", "gunicorn_config.py", "app:app"]
```

#### 2. Пересоберите образ

```bash
docker-compose build
docker-compose up -d
```

## SSL сертификаты

### Вариант 1: Let's Encrypt (Бесплатный SSL)

```bash
# Установите certbot
sudo apt-get install certbot python3-certbot-nginx

# Получите сертификат
sudo certbot --nginx -d your-domain.com

# Сертификаты будут обновляться автоматически
```

### Вариант 2: Самоподписанный сертификат

```bash
openssl req -x509 -newkey rsa:4096 -nodes \
  -out ssl/cert.pem -keyout ssl/key.pem \
  -days 365 \
  -subj "/CN=your-domain.com"
```

## Управление приложением

### Просмотр логов

```bash
docker-compose logs -f web
```

### Перезапуск

```bash
docker-compose restart
```

### Остановка

```bash
docker-compose down
```

### Обновление приложения

```bash
git pull
docker-compose build
docker-compose up -d
```

### Резервное копирование БД

```bash
# Создайте бэкап
docker-compose exec web cp /app/data/articles.db /app/data/articles.db.backup

# Или скопируйте на хост
docker cp infobez-app:/app/data/articles.db ./backup/articles.db.$(date +%Y%m%d)
```

## Мониторинг

### Проверка здоровья контейнера

```bash
docker-compose ps
docker stats
```

### Проверка доступности

```bash
curl http://localhost:5000/
```

## Troubleshooting

### Контейнер не запускается

```bash
# Проверьте логи
docker-compose logs web

# Проверьте конфигурацию
docker-compose config
```

### Проблемы с правами доступа

```bash
# Проверьте права на директории
ls -la data/
chmod 755 data/
```

### Порт уже занят

```bash
# Проверьте, какой процесс использует порт
sudo netstat -tulpn | grep 5000

# Измените порт в docker-compose.yml и .env
```

## Автоматический запуск при перезагрузке

Docker Compose уже настроен на автоматический перезапуск (`restart: unless-stopped`).

Для дополнительной надежности можно создать systemd service:

`/etc/systemd/system/infobez.service`:
```ini
[Unit]
Description=Infobez Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/infobez
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Активируйте:
```bash
sudo systemctl enable infobez
sudo systemctl start infobez
```

## Безопасность

1. **Измените SECRET_KEY** в `.env`
2. **Установите надежный ADMIN_PASSWORD**
3. **Используйте HTTPS** с настоящими сертификатами
4. **Настройте файрвол:**
   ```bash
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 80/tcp    # HTTP
   sudo ufw allow 443/tcp   # HTTPS
   sudo ufw enable
   ```
5. **Регулярно обновляйте** Docker образы и зависимости

## Дополнительные ресурсы

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Gunicorn Documentation](https://gunicorn.org/)
- [Let's Encrypt](https://letsencrypt.org/)

