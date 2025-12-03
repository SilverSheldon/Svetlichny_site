# Используем официальный образ Python
FROM python:3.11-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Копируем файл с зависимостями
COPY requirements.txt .

# Устанавливаем Python зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем все файлы приложения
COPY . .

# Создаем директории для БД и SSL сертификатов
RUN mkdir -p ssl data && \
    chmod 755 ssl data

# Создаем пользователя для запуска приложения (безопасность)
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Переключаемся на непривилегированного пользователя
USER appuser

# Открываем порт (по умолчанию 5000, можно изменить через переменные окружения)
EXPOSE 6000

# Команда по умолчанию (можно переопределить)
CMD ["python", "app.py"]

