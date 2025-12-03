#!/bin/bash
set -e

# Создаем директории если их нет
mkdir -p /app/data /app/ssl

# Убеждаемся, что у нас есть права на запись в data/
# (на случай если volume был создан с неправильными правами)
if [ -w /app/data ]; then
    echo "Директория /app/data доступна для записи"
else
    echo "Предупреждение: возможны проблемы с правами доступа к /app/data"
fi

# Инициализация базы данных если её нет
if [ ! -f /app/data/articles.db ]; then
    echo "База данных не найдена, будет создана при первом запуске приложения"
fi

# Запускаем Gunicorn
exec gunicorn --config gunicorn_config.py app:app

