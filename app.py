from flask import Flask, render_template, request, redirect, url_for, flash, session
import sqlite3
import os
from datetime import datetime
from functools import wraps

app = Flask(__name__)

# Конфигурация из переменных окружения
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-change-this-in-production')
app.config['PREFERRED_URL_SCHEME'] = os.environ.get('PREFERRED_URL_SCHEME', 'https')
app.config['SERVER_NAME'] = os.environ.get('SERVER_NAME', 'infobez')

# Настройки для Docker/production
FLASK_ENV = os.environ.get('FLASK_ENV', 'development')
FLASK_DEBUG = os.environ.get('FLASK_DEBUG', 'True').lower() == 'true'
PORT = int(os.environ.get('PORT', 6000))
HOST = os.environ.get('HOST', '0.0.0.0')
SSL_ENABLED = os.environ.get('SSL_ENABLED', 'false').lower() == 'true'

@app.before_request
def force_https():
    """Перенаправлять HTTP на HTTPS (если сертификаты доступны)"""
    # Проверяем, доступны ли SSL сертификаты
    cert_file = 'ssl/cert.pem'
    key_file = 'ssl/key.pem'
    
    if os.path.exists(cert_file) and os.path.exists(key_file):
        # Если используется HTTP, перенаправляем на HTTPS
        if request.url.startswith('http://'):
            url = request.url.replace('http://', 'https://', 1)
            return redirect(url, code=301)
    
@app.after_request
def add_security_headers(response):
    """Добавить заголовки безопасности для HTTPS"""
    cert_file = 'ssl/cert.pem'
    key_file = 'ssl/key.pem'
    
    # Добавляем заголовки безопасности только если используется HTTPS
    if os.path.exists(cert_file) and os.path.exists(key_file):
        # Добавляем HSTS заголовок (Strict-Transport-Security)
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    
    # Общие заголовки безопасности
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    return response

DATABASE = os.environ.get('DATABASE_PATH', 'articles.db')

# Пароль для админки (из переменных окружения)
ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD', 'admin123')

def get_db():
    """Получить соединение с базой данных"""
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Инициализировать базу данных"""
    conn = get_db()
    conn.execute('''
        CREATE TABLE IF NOT EXISTS articles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            date TEXT NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

def init_articles():
    """Добавить начальные статьи в БД если их нет"""
    conn = get_db()
    count = conn.execute('SELECT COUNT(*) as count FROM articles').fetchone()['count']
    
    if count == 0:
        initial_articles = [
            {
                'title': 'Основы информационной безопасности',
                'content': 'Информационная безопасность — это защита информации от любых действий, которые могут привести к потере данных, их изменению или несанкционированному использованию. Основные принципы включают конфиденциальность, целостность и доступность информации.',
                'date': '2024-01-15'
            },
            {
                'title': 'Защита от фишинга',
                'content': 'Фишинг — один из самых распространенных методов кибератак. Злоумышленники пытаются получить конфиденциальную информацию, выдавая себя за надежные источники. Важно всегда проверять адреса сайтов, не переходить по подозрительным ссылкам и не передавать пароли третьим лицам.',
                'date': '2024-01-20'
            },
            {
                'title': 'Надежные пароли: как создать и хранить',
                'content': 'Создание надежного пароля — основа защиты аккаунтов. Используйте комбинацию букв (заглавных и строчных), цифр и специальных символов. Длина пароля должна быть не менее 12 символов. Никогда не используйте один пароль для нескольких аккаунтов и рассмотрите возможность использования менеджера паролей.',
                'date': '2024-02-01'
            },
            {
                'title': 'Двухфакторная аутентификация',
                'content': 'Двухфакторная аутентификация (2FA) значительно повышает безопасность ваших аккаунтов. Она требует не только пароль, но и дополнительный код, который обычно приходит на ваш телефон или генерируется приложением. Это делает практически невозможным несанкционированный доступ к вашим данным.',
                'date': '2024-02-10'
            },
            {
                'title': 'Обновление программного обеспечения',
                'content': 'Регулярное обновление операционной системы и программного обеспечения критически важно для безопасности. Обновления часто содержат исправления уязвимостей, которые могут быть использованы злоумышленниками. Включите автоматические обновления, чтобы всегда иметь последние версии защитного ПО.',
                'date': '2024-02-15'
            }
        ]
        
        for article in initial_articles:
            conn.execute(
                'INSERT INTO articles (title, content, date) VALUES (?, ?, ?)',
                (article['title'], article['content'], article['date'])
            )
        
        conn.commit()
    
    conn.close()

def login_required(f):
    """Декоратор для проверки авторизации"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('admin_logged_in'):
            flash('Пожалуйста, войдите в систему для доступа к админ-панели.')
            return redirect(url_for('admin_login'))
        return f(*args, **kwargs)
    return decorated_function

# Инициализация БД при запуске
if not os.path.exists(DATABASE):
    init_db()
    init_articles()

# Публичные маршруты
@app.route('/')
def index():
    conn = get_db()
    articles = conn.execute('SELECT * FROM articles ORDER BY date DESC').fetchall()
    conn.close()
    # Преобразуем Row объекты в словари
    articles_list = [dict(article) for article in articles]
    return render_template('index.html', articles=articles_list)

@app.route('/article/<int:article_id>')
def article(article_id):
    conn = get_db()
    article_data = conn.execute('SELECT * FROM articles WHERE id = ?', (article_id,)).fetchone()
    conn.close()
    
    if article_data is None:
        return render_template('404.html'), 404
    
    return render_template('article.html', article=dict(article_data))

@app.route('/about')
def about():
    return render_template('about.html')

# Админ-панель - авторизация
@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        password = request.form.get('password')
        if password == ADMIN_PASSWORD:
            session['admin_logged_in'] = True
            flash('Вы успешно вошли в систему!')
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Неверный пароль!')
    return render_template('admin/login.html')

@app.route('/admin/logout')
def admin_logout():
    session.pop('admin_logged_in', None)
    flash('Вы вышли из системы.')
    return redirect(url_for('index'))

# Админ-панель - главная
@app.route('/admin')
@login_required
def admin_dashboard():
    conn = get_db()
    articles = conn.execute('SELECT * FROM articles ORDER BY date DESC').fetchall()
    conn.close()
    articles_list = [dict(article) for article in articles]
    return render_template('admin/dashboard.html', articles=articles_list)

# Админ-панель - добавление статьи
@app.route('/admin/article/new', methods=['GET', 'POST'])
@login_required
def admin_add_article():
    if request.method == 'POST':
        title = request.form.get('title')
        content = request.form.get('content')
        date = request.form.get('date') or datetime.now().strftime('%Y-%m-%d')
        
        if title and content:
            conn = get_db()
            conn.execute(
                'INSERT INTO articles (title, content, date) VALUES (?, ?, ?)',
                (title, content, date)
            )
            conn.commit()
            conn.close()
            flash('Статья успешно добавлена!')
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Заполните все поля!')
    
    return render_template('admin/article_form.html', article=None)

# Админ-панель - редактирование статьи
@app.route('/admin/article/<int:article_id>/edit', methods=['GET', 'POST'])
@login_required
def admin_edit_article(article_id):
    conn = get_db()
    article_data = conn.execute('SELECT * FROM articles WHERE id = ?', (article_id,)).fetchone()
    
    if article_data is None:
        conn.close()
        flash('Статья не найдена!')
        return redirect(url_for('admin_dashboard'))
    
    if request.method == 'POST':
        title = request.form.get('title')
        content = request.form.get('content')
        date = request.form.get('date')
        
        if title and content and date:
            conn.execute(
                'UPDATE articles SET title = ?, content = ?, date = ? WHERE id = ?',
                (title, content, date, article_id)
            )
            conn.commit()
            conn.close()
            flash('Статья успешно обновлена!')
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Заполните все поля!')
    
    conn.close()
    return render_template('admin/article_form.html', article=dict(article_data))

# Админ-панель - удаление статьи
@app.route('/admin/article/<int:article_id>/delete', methods=['POST'])
@login_required
def admin_delete_article(article_id):
    conn = get_db()
    article_data = conn.execute('SELECT * FROM articles WHERE id = ?', (article_id,)).fetchone()
    
    if article_data:
        conn.execute('DELETE FROM articles WHERE id = ?', (article_id,))
        conn.commit()
        flash('Статья успешно удалена!')
    else:
        flash('Статья не найдена!')
    
    conn.close()
    return redirect(url_for('admin_dashboard'))

@app.errorhandler(404)
def not_found(error):
    return render_template('404.html'), 404

if __name__ == '__main__':
    import ssl
    
    # Инициализация БД при первом запуске
    if not os.path.exists(DATABASE):
        init_db()
        init_articles()
    
    # Путь к SSL сертификатам
    cert_file = os.environ.get('SSL_CERT_PATH', 'ssl/cert.pem')
    key_file = os.environ.get('SSL_KEY_PATH', 'ssl/key.pem')
    
    # Проверяем наличие сертификатов и настройки
    use_ssl = SSL_ENABLED and os.path.exists(cert_file) and os.path.exists(key_file)
    
    if use_ssl:
        # Создаем SSL контекст
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(cert_file, key_file)
        
        print("=" * 50)
        print(f"Сервер запущен с HTTPS на {HOST}:{PORT}")
        print(f"URL: {app.config['PREFERRED_URL_SCHEME']}://{app.config['SERVER_NAME']}")
        print("=" * 50)
        
        app.run(
            host=HOST,
            port=PORT,
            debug=FLASK_DEBUG,
            ssl_context=context
        )
    else:
        print("=" * 50)
        if SSL_ENABLED:
            print("ВНИМАНИЕ: SSL сертификаты не найдены!")
        print(f"Сервер запущен без HTTPS на {HOST}:{PORT}")
        print(f"URL: http://{app.config['SERVER_NAME']}:{PORT}")
        print("=" * 50)
        
        app.run(
            host=HOST,
            port=PORT,
            debug=FLASK_DEBUG
        )
