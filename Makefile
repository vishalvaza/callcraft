# CallCraft - Development Makefile

.PHONY: help setup up down logs restart rebuild migrate test clean

# Default target
help:
	@echo "CallCraft Development Commands"
	@echo "=============================="
	@echo "  make setup      - Initial setup (pull LLM model, run migrations)"
	@echo "  make up         - Start all services"
	@echo "  make down       - Stop all services"
	@echo "  make logs       - View logs (all services)"
	@echo "  make logs-api   - View backend API logs"
	@echo "  make restart    - Restart all services"
	@echo "  make rebuild    - Rebuild and restart backend"
	@echo "  make migrate    - Run database migrations"
	@echo "  make test       - Run backend tests"
	@echo "  make shell      - Enter backend container shell"
	@echo "  make db-shell   - Enter PostgreSQL shell"
	@echo "  make clean      - Remove all containers and volumes"

# Initial setup
setup: up
	@echo "Pulling LLM model (this may take a while)..."
	docker exec -it callcraft-ollama ollama pull qwen2.5:7b-instruct
	@echo "Running database migrations..."
	docker exec -it callcraft-backend alembic upgrade head
	@echo "Setup complete! Visit http://localhost:8000/docs"

# Start all services
up:
	docker-compose up -d
	@echo "Services started. Use 'make logs' to view logs."

# Stop all services
down:
	docker-compose down

# View logs
logs:
	docker-compose logs -f

logs-api:
	docker-compose logs -f backend

# Restart services
restart:
	docker-compose restart

# Rebuild backend
rebuild:
	docker-compose up -d --build backend

# Run migrations
migrate:
	docker exec -it callcraft-backend alembic upgrade head

# Create new migration
migration:
	@read -p "Enter migration description: " desc; \
	docker exec -it callcraft-backend alembic revision --autogenerate -m "$$desc"

# Run tests
test:
	docker exec -it callcraft-backend pytest

# Backend shell
shell:
	docker exec -it callcraft-backend bash

# Database shell
db-shell:
	docker exec -it callcraft-postgres psql -U callcraft -d callcraft

# Clean everything
clean:
	docker-compose down -v
	@echo "Cleaned all containers and volumes"

# Development workflow shortcuts
dev-backend:
	cd backend && source venv/bin/activate && uvicorn app.main:app --reload

dev-mobile:
	cd mobile && flutter run
