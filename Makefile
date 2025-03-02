# Makefile for Inception Project

# Variables
DOCKER_COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = ~/data
DOMAIN_NAME = $(USER).42.fr

all: hosts_config dirs up

# Set up hosts file (requires sudo)
hosts_config:
	@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		echo "Adding $(DOMAIN_NAME) to /etc/hosts (may require password)"; \
		sudo sh -c 'echo "127.0.0.1 $(DOMAIN_NAME)" >> /etc/hosts'; \
		sudo sh -c 'echo "127.0.0.1 www.$(DOMAIN_NAME)" >> /etc/hosts'; \
	fi

# Create required directories
dirs:
	mkdir -p $(DATA_PATH)/wordpress
	mkdir -p $(DATA_PATH)/mariadb

# Build and start containers
up: dirs
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d --build

# Stop containers
down:
	docker compose -f $(DOCKER_COMPOSE_FILE) down

# Remove containers, networks and images used by services
clean: down
	docker compose -f $(DOCKER_COMPOSE_FILE) down --volumes --rmi all

# Full cleanup including directories and system prune
fclean: clean
	sudo rm -rf $(DATA_PATH)/wordpress/*
	sudo rm -rf $(DATA_PATH)/mariadb/*
	docker system prune -f
	@echo "Note: If you want to remove entries from /etc/hosts, edit the file manually"

# Rebuild everything
re: fclean all

# List all services status
status:
	@echo "Docker containers status:"
	@docker ps -a
	@echo "\nDocker volumes:"
	@docker volume ls | grep inception
	@echo "\nDocker networks:"
	@docker network ls | grep inception

.PHONY: all hosts_config dirs up down clean fclean re status