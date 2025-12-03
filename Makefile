.PHONY: help build up down restart logs ps shell clean deploy

help: ## Показать справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Собрать Docker образ
	docker-compose build --no-cache

up: ## Запустить контейнеры
	docker-compose up -d

down: ## Остановить и удалить контейнеры
	docker-compose down

restart: ## Перезапустить контейнеры
	docker-compose restart

logs: ## Показать логи
	docker-compose logs -f

ps: ## Показать статус контейнеров
	docker-compose ps

shell: ## Открыть shell в контейнере
	docker-compose exec web bash

clean: ## Остановить контейнеры и удалить volumes (ОСТОРОЖНО!)
	docker-compose down -v

deploy: ## Полный деплой (сборка + запуск)
	docker-compose down || true
	docker-compose build --no-cache
	docker-compose up -d
	@echo "Деплой завершен! Проверьте логи: make logs"

update: ## Обновить приложение (git pull + пересборка)
	git pull
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "Обновление завершено! Проверьте логи: make logs"

backup: ## Создать резервную копию базы данных
	@mkdir -p backup
	docker cp svetlichny_site:/app/data/articles.db ./backup/articles.db.$$(date +%Y%m%d_%H%M%S)
	@echo "Резервная копия создана в директории backup/"

stats: ## Показать использование ресурсов
	docker stats svetlichny_site

