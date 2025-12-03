@echo off
echo ========================================
echo Настройка HTTPS для infobez
echo ========================================
echo.

REM Проверяем наличие OpenSSL
where openssl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ОШИБКА] OpenSSL не найден в PATH
    echo.
    echo Установите OpenSSL одним из способов:
    echo 1. Скачайте с https://slproweb.com/products/Win32OpenSSL.html
    echo 2. Или через Chocolatey: choco install openssl
    echo 3. Или используйте Git Bash (устанавливается вместе с Git)
    echo.
    pause
    exit /b 1
)

echo [1/3] Создание директории ssl...
if not exist ssl mkdir ssl

echo [2/3] Генерация SSL сертификата...
openssl req -x509 -newkey rsa:4096 -nodes -out ssl\cert.pem -keyout ssl\key.pem -days 365 -subj "/C=RU/ST=State/L=City/O=Organization/CN=infobez"

if %ERRORLEVEL% NEQ 0 (
    echo [ОШИБКА] Не удалось создать сертификат
    pause
    exit /b 1
)

echo [3/3] Настройка hosts файла...
echo.
echo ========================================
echo Следующий шаг - добавление записи в hosts файл
echo ========================================
echo.
echo Запустите PowerShell от имени администратора и выполните:
echo.
echo $content = Get-Content C:\Windows\System32\drivers\etc\hosts
echo if ($content -notcontains "127.0.0.1    infobez") {
echo     Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1    infobez"
echo     ipconfig /flushdns
echo }
echo.
echo Или вручную добавьте в файл C:\Windows\System32\drivers\etc\hosts:
echo 127.0.0.1    infobez
echo.
echo ========================================
echo Готово! Теперь запустите от имени администратора:
echo   python app.py
echo URL: https://infobez
echo ========================================
echo.
echo ВАЖНО: Для порта 443 требуются права администратора!
echo.
pause

