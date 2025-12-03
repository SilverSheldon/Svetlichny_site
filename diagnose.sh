#!/bin/bash

# Скрипт диагностики проблем с Docker контейнером

echo "=========================================="
echo "Диагностика Svetlichny Site"
echo "=========================================="

echo ""
echo "1. Проверка статуса контейнеров:"
docker-compose ps

echo ""
echo "2. Последние логи контейнера:"
docker-compose logs --tail=50

echo ""
echo "3. Проверка существования директорий:"
if [ -d "data" ]; then
    echo "  ✓ Директория data/ существует"
    ls -la data/
else
    echo "  ✗ Директория data/ не существует"
fi

if [ -d "ssl" ]; then
    echo "  ✓ Директория ssl/ существует"
    ls -la ssl/
else
    echo "  ✗ Директория ssl/ не существует"
fi

echo ""
echo "4. Проверка .env файла:"
if [ -f ".env" ]; then
    echo "  ✓ Файл .env существует"
    echo "  Проверка ключевых переменных:"
    grep -E "SECRET_KEY|ADMIN_PASSWORD|DATABASE_PATH" .env | sed 's/=.*/=***/'
else
    echo "  ✗ Файл .env не существует"
    echo "  Создайте его: cp env.example .env"
fi

echo ""
echo "5. Проверка порта 6000:"
if netstat -tuln 2>/dev/null | grep -q ":6000"; then
    echo "  ⚠ Порт 6000 уже занят"
    netstat -tuln | grep ":6000"
else
    echo "  ✓ Порт 6000 свободен"
fi

echo ""
echo "6. Проверка Docker образа:"
docker images | grep -E "svetlichny|REPOSITORY" || echo "  Образ не найден"

echo ""
echo "7. Попытка подключения к контейнеру:"
if docker ps | grep -q svetlichny_site; then
    echo "  ✓ Контейнер запущен"
    echo "  Попытка выполнить команду внутри контейнера:"
    docker exec svetlichny_site ls -la /app/data 2>&1 || echo "  ✗ Не удалось подключиться"
else
    echo "  ✗ Контейнер не запущен"
fi

echo ""
echo "=========================================="
echo "Диагностика завершена"
echo "=========================================="

