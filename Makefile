# Makefile для удобного управления приложением

.PHONY: help build up down restart logs clean shell backup

help: ## Показать эту справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Собрать Docker образ
	docker-compose build

up: ## Запустить контейнеры
	docker-compose up -d

down: ## Остановить контейнеры
	docker-compose down

restart: ## Перезапустить контейнеры
	docker-compose restart

logs: ## Показать логи
	docker-compose logs -f

logs-web: ## Показать логи только веб-сервера
	docker-compose logs -f web

ps: ## Показать статус контейнеров
	docker-compose ps

shell: ## Войти в контейнер (интерактивная оболочка)
	docker-compose exec web bash

clean: ## Остановить и удалить контейнеры, volumes
	docker-compose down -v

backup: ## Создать резервную копию БД
	@mkdir -p backup
	docker cp infobez-app:/app/data/articles.db ./backup/articles.db.$$(date +%Y%m%d_%H%M%S)
	@echo "Резервная копия создана в ./backup/"

restore: ## Восстановить БД из резервной копии (использование: make restore BACKUP=backup/articles.db.20240101_120000)
	@if [ -z "$(BACKUP)" ]; then \
		echo "Ошибка: Укажите путь к резервной копии"; \
		echo "Использование: make restore BACKUP=backup/articles.db.20240101_120000"; \
		exit 1; \
	fi
	docker cp $(BACKUP) infobez-app:/app/data/articles.db
	docker-compose restart
	@echo "БД восстановлена из $(BACKUP)"

deploy: ## Полный деплой (сборка + запуск)
	./deploy.sh

status: ## Проверить здоровье приложения
	@docker-compose ps
	@echo ""
	@echo "Проверка доступности:"
	@curl -f http://localhost:5000/ && echo "✓ Приложение работает" || echo "✗ Приложение недоступно"

