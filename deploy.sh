#!/bin/bash

# Скрипт деплоя для сервера
# Использование: ./deploy.sh

set -e  # Остановка при ошибке

echo "=========================================="
echo "Деплой Svetlichny Site на сервер"
echo "=========================================="

# Проверка наличия Docker и Docker Compose
if ! command -v docker &> /dev/null; then
    echo "Ошибка: Docker не установлен!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Ошибка: Docker Compose не установлен!"
    exit 1
fi

# Создание необходимых директорий
echo "Создание необходимых директорий..."
mkdir -p data ssl

# Проверка наличия .env файла
if [ ! -f .env ]; then
    echo "Предупреждение: .env файл не найден!"
    echo "Создайте .env файл на основе .env.production"
    echo "Или скопируйте: cp .env.production .env"
    read -p "Продолжить без .env? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Остановка и удаление старых контейнеров
echo "Остановка старых контейнеров..."
docker-compose down || true

# Сборка новых образов
echo "Сборка Docker образа..."
docker-compose build --no-cache

# Запуск контейнеров
echo "Запуск контейнеров..."
docker-compose up -d

# Ожидание запуска
echo "Ожидание запуска сервиса..."
sleep 5

# Проверка статуса
echo "Проверка статуса контейнеров..."
docker-compose ps

# Показ логов
echo "Последние логи:"
docker-compose logs --tail=50

echo "=========================================="
echo "Деплой завершен!"
echo "Сервис доступен по адресу: http://45.8.99.227:6000"
echo "Для просмотра логов: docker-compose logs -f"
echo "Для остановки: docker-compose down"
echo "=========================================="

