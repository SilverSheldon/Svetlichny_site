# PowerShell скрипт для генерации самоподписанного SSL сертификата для Windows

$sslDir = "ssl"
$certFile = "$sslDir\cert.pem"
$keyFile = "$sslDir\key.pem"

# Создаем директорию если её нет
if (-not (Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir
}

# Проверяем, есть ли уже сертификат
if ((Test-Path $certFile) -and (Test-Path $keyFile)) {
    Write-Host "Сертификаты уже существуют в директории $sslDir/" -ForegroundColor Yellow
    exit
}

Write-Host "Генерация самоподписанного SSL сертификата для infobez..." -ForegroundColor Green

# Создаем сертификат через PowerShell
try {
    $cert = New-SelfSignedCertificate `
        -DnsName "infobez" `
        -CertStoreLocation "cert:\LocalMachine\My" `
        -KeyExportPolicy Exportable `
        -KeySpec Signature `
        -KeyLength 2048 `
        -KeyAlgorithm RSA `
        -HashAlgorithm SHA256 `
        -NotAfter (Get-Date).AddYears(1)
    
    Write-Host "Сертификат создан в хранилище Windows" -ForegroundColor Green
    
    # Экспортируем сертификат и ключ
    $pwd = ConvertTo-SecureString -String "temp_password" -Force -AsPlainText
    
    # Экспорт сертификата в PFX
    $pfxPath = "$sslDir\infobez.pfx"
    Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $pwd
    
    # Экспорт в PEM формате требует дополнительных инструментов
    Write-Host "`nВнимание: Для работы с Flask нужны файлы в формате PEM." -ForegroundColor Yellow
    Write-Host "Используйте OpenSSL для конвертации:" -ForegroundColor Yellow
    Write-Host "  openssl pkcs12 -in $pfxPath -out $certFile -clcerts -nokeys -passin pass:temp_password" -ForegroundColor Cyan
    Write-Host "  openssl pkcs12 -in $pfxPath -out $keyFile -nocerts -nodes -passin pass:temp_password" -ForegroundColor Cyan
    Write-Host "`nИли используйте Python скрипт generate_cert.py с установленным OpenSSL" -ForegroundColor Yellow
    
} catch {
    Write-Host "Ошибка: $_" -ForegroundColor Red
    Write-Host "`nПопробуйте использовать Python скрипт generate_cert.py" -ForegroundColor Yellow
}

