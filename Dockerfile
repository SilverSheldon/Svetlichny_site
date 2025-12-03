# Используем официальный Python образ
FROM python:3.11-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Копируем файл зависимостей
COPY requirements.txt .

# Устанавливаем Python зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения (сначала как root)
COPY . .

# Создаем пользователя для запуска приложения (безопасность)
RUN useradd -m -u 1000 appuser && \
    mkdir -p /app/data /app/ssl && \
    chmod +x /app/entrypoint.sh && \
    chown -R appuser:appuser /app

# Переключаемся на непривилегированного пользователя
USER appuser

# Открываем порт
EXPOSE 6000

# Используем entrypoint скрипт
ENTRYPOINT ["/app/entrypoint.sh"]

