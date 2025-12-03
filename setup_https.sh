#!/bin/bash

echo "========================================"
echo "Настройка HTTPS для infobez"
echo "========================================"
echo ""

# Проверяем наличие OpenSSL
if ! command -v openssl &> /dev/null; then
    echo "[ОШИБКА] OpenSSL не найден"
    echo ""
    echo "Установите OpenSSL:"
    echo "  Ubuntu/Debian: sudo apt-get install openssl"
    echo "  macOS: brew install openssl"
    echo ""
    exit 1
fi

echo "[1/3] Создание директории ssl..."
mkdir -p ssl

echo "[2/3] Генерация SSL сертификата..."
openssl req -x509 -newkey rsa:4096 -nodes -out ssl/cert.pem -keyout ssl/key.pem -days 365 -subj "/C=RU/ST=State/L=City/O=Organization/CN=infobez"

if [ $? -ne 0 ]; then
    echo "[ОШИБКА] Не удалось создать сертификат"
    exit 1
fi

echo "[3/3] Настройка hosts файла..."
echo ""
echo "========================================"
echo "Добавление записи в hosts файл"
echo "========================================"
echo ""

# Проверяем, есть ли уже запись
if grep -q "infobez" /etc/hosts; then
    echo "Запись для infobez уже существует в /etc/hosts"
else
    echo "Требуется sudo для добавления записи в /etc/hosts"
    echo "127.0.0.1    infobez" | sudo tee -a /etc/hosts > /dev/null
    echo "✓ Запись добавлена в /etc/hosts"
fi

echo ""
echo "========================================"
echo "Готово! Теперь запустите от имени root:"
echo "  sudo python app.py"
echo "URL: https://infobez"
echo "========================================"
echo ""
echo "ВАЖНО: Для порта 443 требуются права root!"
echo ""

