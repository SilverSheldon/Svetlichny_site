# Быстрый старт с Docker

## Локальный запуск

### 1. Клонируйте репозиторий или перейдите в директорию проекта

```bash
cd test_site
```

### 2. Создайте необходимые директории

```bash
mkdir -p data ssl
```

### 3. Настройте переменные окружения (опционально)

Создайте файл `.env` на основе `.env.example`:

```bash
cp .env.example .env
nano .env  # Отредактируйте значения
```

**Минимум, что нужно изменить:**
- `SECRET_KEY` - сгенерируйте случайную строку
- `ADMIN_PASSWORD` - установите надежный пароль

### 4. Запустите приложение

```bash
# Сборка и запуск
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Проверка статуса
docker-compose ps
```

### 5. Откройте в браузере

```
http://localhost:5000
```

## Команды управления

```bash
# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Пересборка и запуск
docker-compose up -d --build

# Просмотр логов
docker-compose logs -f web

# Выполнение команд в контейнере
docker-compose exec web bash
```

## Production деплой

Подробная инструкция доступна в [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md)

## Структура проекта

```
test_site/
├── app.py                 # Основное приложение
├── Dockerfile             # Docker образ
├── docker-compose.yml     # Docker Compose конфигурация
├── requirements.txt       # Python зависимости
├── gunicorn_config.py     # Конфигурация Gunicorn
├── .dockerignore          # Исключения для Docker
├── data/                  # Данные БД (монтируется как volume)
├── ssl/                   # SSL сертификаты (монтируется как volume)
└── templates/             # HTML шаблоны
```

## Переменные окружения

| Переменная | Описание | По умолчанию |
|-----------|----------|--------------|
| `SECRET_KEY` | Секретный ключ Flask | `your-secret-key...` |
| `ADMIN_PASSWORD` | Пароль админ-панели | `admin123` |
| `PORT` | Порт приложения | `5000` |
| `FLASK_ENV` | Окружение Flask | `production` |
| `FLASK_DEBUG` | Режим отладки | `False` |
| `SERVER_NAME` | Доменное имя | `infobez` |
| `DATABASE_PATH` | Путь к БД | `/app/data/articles.db` |

Полный список в файле `.env.example`

## Troubleshooting

### Контейнер не запускается

```bash
# Проверьте логи
docker-compose logs web

# Проверьте конфигурацию
docker-compose config
```

### Порт занят

Измените порт в `docker-compose.yml`:
```yaml
ports:
  - "8080:5000"  # Используйте другой внешний порт
```

### Проблемы с правами доступа

```bash
# Проверьте права на директории
ls -la data/
chmod 755 data/
```

## Резервное копирование

```bash
# Создайте бэкап БД
docker cp infobez-app:/app/data/articles.db ./backup/articles.db.$(date +%Y%m%d)

# Восстановление
docker cp ./backup/articles.db infobez-app:/app/data/articles.db
docker-compose restart
```

## Дополнительная информация

- [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md) - подробная инструкция по деплою
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

