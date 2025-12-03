# Быстрое решение проблем

## Если контейнер не запускается, выполните эти команды по порядку:

### 1. Проверьте логи
```bash
docker-compose logs --tail=100
```

### 2. Убедитесь, что директории созданы с правильными правами
```bash
mkdir -p data ssl
chmod 755 data ssl
```

### 3. Проверьте .env файл
```bash
# Убедитесь, что файл существует
ls -la .env

# Если нет, создайте
cp env.example .env
# Отредактируйте .env и установите SECRET_KEY и ADMIN_PASSWORD
```

### 4. Пересоберите и перезапустите
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 5. Следите за логами в реальном времени
```bash
docker-compose logs -f
```

## Частые ошибки:

### "Permission denied" в логах
```bash
# Исправьте права на директорию data
sudo chown -R $USER:$USER data
chmod 755 data
docker-compose restart
```

### "Port 6000 already in use"
```bash
# Найдите и остановите процесс
sudo lsof -i :6000
# Или измените порт в docker-compose.yml
```

### Контейнер сразу останавливается
```bash
# Проверьте логи для деталей
docker-compose logs
# Убедитесь, что все файлы на месте
ls -la app.py gunicorn_config.py requirements.txt
```

## Если ничего не помогает:

Запустите полную диагностику:
```bash
chmod +x diagnose.sh
./diagnose.sh
```

Или выполните полную переустановку:
```bash
docker-compose down -v
docker system prune -f
mkdir -p data ssl
chmod 755 data ssl
docker-compose build --no-cache
docker-compose up -d
docker-compose logs -f
```

