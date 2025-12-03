# Быстрый старт с HTTPS

## Windows

1. **Создайте SSL сертификат:**
   ```batch
   setup_https.bat
   ```
   Или вручную:
   ```batch
   python generate_cert.py
   ```

2. **Добавьте домен в hosts файл:**
   
   Откройте PowerShell от имени администратора:
   ```powershell
   Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1    infobez"
   ipconfig /flushdns
   ```

3. **Запустите приложение от имени администратора:**
   
   Важно: для порта 443 (стандартный HTTPS) требуются права администратора!
   
   ```batch
   python app.py
   ```

4. **Откройте в браузере:**
   ```
   https://infobez
   ```

## Linux / macOS

1. **Создайте SSL сертификат:**
   ```bash
   chmod +x setup_https.sh
   ./setup_https.sh
   ```
   Или вручную:
   ```bash
   python generate_cert.py
   sudo nano /etc/hosts  # добавьте: 127.0.0.1    infobez
   ```

2. **Запустите приложение от имени администратора:**
   
   Важно: для порта 443 (стандартный HTTPS) требуются права root!
   
   ```bash
   sudo python app.py
   ```

3. **Откройте в браузере:**
   ```
   https://infobez
   ```

## Предупреждение браузера

При первом посещении браузер покажет предупреждение о небезопасном сертификате. Это нормально для локальной разработки - просто нажмите "Дополнительно" → "Продолжить".

## Пароль админки

По умолчанию: `admin123`

Вход: `https://infobez/admin/login`

