"""
Скрипт для генерации самоподписанного SSL сертификата для локальной разработки
"""
import os
import subprocess
import sys

def generate_cert():
    """Генерировать самоподписанный SSL сертификат"""
    ssl_dir = 'ssl'
    
    if not os.path.exists(ssl_dir):
        os.makedirs(ssl_dir)
    
    cert_file = os.path.join(ssl_dir, 'cert.pem')
    key_file = os.path.join(ssl_dir, 'key.pem')
    
    # Проверяем, есть ли уже сертификат
    if os.path.exists(cert_file) and os.path.exists(key_file):
        print(f"Сертификаты уже существуют в директории {ssl_dir}/")
        return
    
    # Попытка использовать openssl
    try:
        print("Генерация самоподписанного SSL сертификата...")
        print("Домен: infobez")
        
        # Команда для создания сертификата
        cmd = [
            'openssl', 'req', '-x509', '-newkey', 'rsa:4096',
            '-nodes', '-out', cert_file, '-keyout', key_file,
            '-days', '365',
            '-subj', '/C=RU/ST=State/L=City/O=Organization/CN=infobez'
        ]
        
        subprocess.run(cmd, check=True)
        print(f"✓ Сертификат успешно создан!")
        print(f"  Certificate: {cert_file}")
        print(f"  Key: {key_file}")
        
    except FileNotFoundError:
        print("Ошибка: OpenSSL не найден в системе.")
        print("\nДля Windows:")
        print("1. Установите OpenSSL с https://slproweb.com/products/Win32OpenSSL.html")
        print("   или через Chocolatey: choco install openssl")
        print("2. Добавьте OpenSSL в PATH")
        print("\nАльтернативный способ - использовать PowerShell:")
        print("   New-SelfSignedCertificate -DnsName infobez -CertStoreLocation cert:\\LocalMachine\\My")
        print("\nИли используйте готовый скрипт для PowerShell в generate_cert.ps1")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Ошибка при генерации сертификата: {e}")
        sys.exit(1)

if __name__ == '__main__':
    generate_cert()

