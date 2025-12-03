# Быстрый старт с Docker

## Деплой на сервер 45.8.99.227

### 1. Подготовка

```bash
# Клонируйте проект на сервер
git clone <repository-url>
cd Svetlichny_site

# Создайте .env файл
cp env.example .env
# Отредактируйте .env и установите SECRET_KEY и ADMIN_PASSWORD
```

### 2. Запуск

```bash
# Сделайте скрипт исполняемым
chmod +x deploy.sh

# Запустите деплой
./deploy.sh
```

### 3. Доступ

- **Сайт:** http://45.8.99.227:6000
- **Админ-панель:** http://45.8.99.227:6000/admin

## Основные команды

```bash
# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose stop

# Запуск
docker-compose start

# Перезапуск
docker-compose restart

# Обновление
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

Подробная документация: [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md)

