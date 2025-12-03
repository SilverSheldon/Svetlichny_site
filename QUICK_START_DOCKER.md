# Быстрый старт с Docker

## Минимальные шаги для запуска

### 1. Создайте директории
```bash
mkdir -p data ssl
```

### 2. Запустите приложение
```bash
docker-compose up -d
```

### 3. Откройте в браузере
```
http://localhost:5000
```

Всё! Приложение запущено. База данных инициализируется автоматически при первом запуске.

## Основные команды

```bash
# Запуск
docker-compose up -d

# Остановка
docker-compose down

# Логи
docker-compose logs -f

# Перезапуск
docker-compose restart
```

## Настройка (опционально)

Создайте файл `.env` для изменения настроек:
```bash
cp env.example .env
# Отредактируйте .env
```

Важно изменить:
- `SECRET_KEY` - сгенерируйте случайную строку
- `ADMIN_PASSWORD` - установите надежный пароль

## Админ-панель

URL: `http://localhost:5000/admin/login`
Пароль по умолчанию: `admin123`

## Подробная документация

- [README_DOCKER.md](README_DOCKER.md) - подробная документация
- [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md) - инструкция по деплою на сервер

