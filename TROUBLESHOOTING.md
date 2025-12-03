# Устранение неполадок

## Проблема: Контейнер не запускается

### Шаг 1: Диагностика

Запустите скрипт диагностики:

```bash
chmod +x diagnose.sh
./diagnose.sh
```

Или вручную проверьте:

```bash
# Статус контейнеров
docker-compose ps

# Логи контейнера
docker-compose logs --tail=100

# Проверка образа
docker images | grep svetlichny
```

### Шаг 2: Типичные проблемы и решения

#### Проблема: Контейнер сразу останавливается (Exit code 1)

**Причина:** Ошибка при запуске приложения

**Решение:**
1. Проверьте логи: `docker-compose logs`
2. Убедитесь, что все файлы скопированы правильно
3. Проверьте права доступа к директории `data/`:

```bash
# Создайте директорию если её нет
mkdir -p data
chmod 755 data

# Пересоберите контейнер
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

#### Проблема: Permission denied при записи в базу данных

**Причина:** Неправильные права доступа к директории `data/`

**Решение:**

```bash
# На хосте создайте директорию с правильными правами
mkdir -p data
sudo chown -R $USER:$USER data
chmod 755 data

# Перезапустите контейнер
docker-compose restart
```

Если проблема сохраняется, временно запустите контейнер от root для проверки:

```bash
# Временно измените docker-compose.yml, добавьте:
# user: "root"
# Затем перезапустите
```

#### Проблема: Порт 6000 уже занят

**Причина:** Другой процесс использует порт 6000

**Решение:**

```bash
# Найдите процесс, использующий порт
sudo netstat -tulpn | grep 6000
# или
sudo lsof -i :6000

# Остановите процесс или измените порт в docker-compose.yml
```

#### Проблема: ModuleNotFoundError или ImportError

**Причина:** Зависимости не установлены правильно

**Решение:**

```bash
# Пересоберите образ
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Проверьте requirements.txt
docker-compose exec web pip list
```

#### Проблема: База данных не создается

**Причина:** Нет прав на запись в директорию `/app/data`

**Решение:**

```bash
# Проверьте права на хосте
ls -la data/

# Убедитесь, что директория существует и доступна
mkdir -p data
chmod 777 data  # Временно для диагностики

# Проверьте внутри контейнера
docker-compose exec web ls -la /app/data
docker-compose exec web touch /app/data/test.txt
```

#### Проблема: Контейнер запускается, но сайт недоступен

**Причина:** Firewall или неправильная конфигурация сети

**Решение:**

```bash
# Проверьте, что контейнер слушает правильный порт
docker-compose exec web netstat -tuln | grep 6000

# Проверьте firewall
sudo ufw status
sudo ufw allow 6000/tcp

# Проверьте, что приложение отвечает внутри контейнера
docker-compose exec web curl http://localhost:6000/

# Проверьте логи
docker-compose logs -f
```

### Шаг 3: Полная переустановка

Если ничего не помогает:

```bash
# Остановите и удалите все
docker-compose down -v
docker rmi $(docker images | grep svetlichny | awk '{print $3}') || true

# Убедитесь, что директории созданы
mkdir -p data ssl
chmod 755 data ssl

# Проверьте .env файл
cat .env

# Пересоберите и запустите
docker-compose build --no-cache
docker-compose up -d

# Следите за логами
docker-compose logs -f
```

## Проблема: Ошибки в логах

### Ошибка: "Address already in use"

Порт занят. Измените порт в `docker-compose.yml` или освободите порт.

### Ошибка: "Permission denied"

Проблема с правами доступа. См. раздел выше про Permission denied.

### Ошибка: "No such file or directory: '/app/data/articles.db'"

База данных не создается. Проверьте права на директорию `data/`.

### Ошибка: "ImportError: No module named 'flask'"

Зависимости не установлены. Пересоберите образ.

## Проблема: Медленная работа

### Увеличьте количество workers

В `.env` файле:
```
GUNICORN_WORKERS=8
```

Перезапустите контейнер.

## Получение помощи

Если проблема не решена:

1. Соберите информацию:
   ```bash
   ./diagnose.sh > diagnosis.txt
   docker-compose logs > logs.txt
   ```

2. Проверьте:
   - Версию Docker: `docker --version`
   - Версию Docker Compose: `docker-compose --version`
   - Свободное место на диске: `df -h`
   - Использование памяти: `free -h`

3. Попробуйте запустить приложение без Docker для проверки:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   python app.py
   ```

