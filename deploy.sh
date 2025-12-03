#!/bin/bash

# Скрипт для деплоя приложения

set -e

echo "=========================================="
echo "Деплой приложения Infobez"
echo "=========================================="
echo ""

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
    echo "Ошибка: Docker не установлен!"
    exit 1
fi

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Ошибка: Docker Compose не установлен!"
    exit 1
fi

# Создание необходимых директорий
echo "[1/5] Создание директорий..."
mkdir -p data ssl
chmod 755 data ssl

# Проверка файла .env
if [ ! -f .env ]; then
    echo ""
    echo "ВНИМАНИЕ: Файл .env не найден!"
    echo "Создайте его на основе .env.example:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    echo ""
    read -p "Продолжить без .env? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Сборка образа
echo ""
echo "[2/5] Сборка Docker образа..."
docker-compose build

# Остановка старых контейнеров
echo ""
echo "[3/5] Остановка старых контейнеров..."
docker-compose down

# Запуск новых контейнеров
echo ""
echo "[4/5] Запуск контейнеров..."
docker-compose up -d

# Ожидание запуска
echo ""
echo "[5/5] Ожидание запуска приложения..."
sleep 5

# Проверка статуса
echo ""
echo "=========================================="
echo "Проверка статуса..."
echo "=========================================="
docker-compose ps

echo ""
echo "=========================================="
echo "Деплой завершен!"
echo "=========================================="
echo ""
echo "Просмотр логов: docker-compose logs -f"
echo "Остановка: docker-compose down"
echo "Перезапуск: docker-compose restart"
echo ""

