.PHONY: env project build clean archive refresh list web docker-build docker-run docker-stop docker-logs docker-restart help

# Project variables
VENV := .venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

help:
	@echo "Usage:"
	@echo "  make env                - Setup local environment and install dependencies"
	@echo "  make project            - Interactively create a new project configuration"
	@echo "  make list               - List all projects and their status"
	@echo "  make build NAME=<name>  - Run repomix for a specific project"
	@echo "  make refresh NAME=<name> - Pull latest changes from remote (git projects only)"
	@echo "  make clean NAME=<name>  - Clean outputs for a specific project"
	@echo "  make archive NAME=<name> - Archive a project and remove it from projects/"
	@echo "  make web                - Start the web interface locally"
	@echo "  make docker-build       - Build the Docker image"
	@echo "  make docker-run         - Run the web interface in a Docker container"
	@echo "  make docker-stop        - Stop the Docker container"
	@echo "  make docker-logs        - Tail the Docker container logs"
	@echo "  make docker-restart     - Stop, rebuild, and restart the container"

env:
	@echo "Setting up environment..."
	@if [ ! -d "$(VENV)" ]; then python3 -m venv $(VENV); fi
	@$(PIP) install --upgrade pip
	@$(PIP) install pyyaml click fastapi uvicorn pydantic python-multipart
	@if [ "$$(uname)" = "Darwin" ]; then \
		if ! command -v repomix >/dev/null 2>&1; then \
			echo "Installing repomix via brew..."; \
			brew install repomix; \
		else \
			echo "repomix is already installed."; \
		fi \
	fi
	@mkdir -p projects archive repos
	@echo "Environment setup complete."

project:
	@$(PYTHON) manage_projects.py create

list:
	@$(PYTHON) manage_projects.py list

build:
	@if [ -z "$(NAME)" ]; then echo "Error: NAME is required. Example: make build NAME=my-project"; exit 1; fi
	@$(PYTHON) manage_projects.py build $(NAME)

refresh:
	@if [ -z "$(NAME)" ]; then echo "Error: NAME is required. Example: make refresh NAME=my-project"; exit 1; fi
	@$(PYTHON) manage_projects.py refresh $(NAME)

clean:
	@if [ -z "$(NAME)" ]; then echo "Error: NAME is required. Example: make clean NAME=my-project"; exit 1; fi
	@$(PYTHON) manage_projects.py clean $(NAME)

archive:
	@if [ -z "$(NAME)" ]; then echo "Error: NAME is required. Example: make archive NAME=my-project"; exit 1; fi
	@$(PYTHON) manage_projects.py archive $(NAME)

web:
	@echo "Starting web server on http://localhost:8000..."
	@$(PYTHON) server.py

DOCKER_IMAGE := repomix-maker
DOCKER_CONTAINER := repomix-maker-instance

docker-build:
	@echo "Building Docker image with docker-compose..."
	@docker compose build

docker-run:
	@echo "Running container with docker-compose..."
	@docker compose up -d
	@echo "Web interface is now running at http://localhost:8052"

docker-stop:
	@echo "Stopping and removing container with docker-compose..."
	@docker compose down

docker-logs:
	@docker compose logs -f

docker-restart: docker-stop docker-build docker-run
