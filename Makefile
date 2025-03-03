# Makefile for Inception Project

# # Variables
Docker_Compose_File = srcs/docker-compose.yml
Data_Path = ~/data
Domain_Name = $(USER).42.fr

all: host_config up

# Set up hosts file (requires sudo)
host_config:
	@if ! grep -q "$(Domain_Name)" /ete/hosts; then\
	echo "Adding $(Domain_Name) to /etc/hosts"; \
	sudo sh -c 'echo "127.0.0.1 $(Domain_Name)" >> /etc/hosts'; \
	sudo sh -c 'echo "127.0.0.1 www.$(Domain_Name)" >> /etc/hosts'; \
	fi

# Create required directories
backup_dirs:
	mkdir -p $(Data_Path)/wordpress
	mkdir -p $(Data_Path)/mariadb

# Build and start containers
up: backup_dirs
	docker compose -f $(Docker_Compose_File) up -d --build

# Stop containers only
down:
	docker compose -f $(Docker_Compose_File) down

# Stop containers and Clean up project data directories
clean:
	docker compose -f $(Docker_Compose_File) down --volumes --rmi all

# Full cleanup including directories
fclean: clean
	sudo rm -rf $(Data_Path)/wordpress/*
	sudo rm -rf $(Data_Path)/mariadb/*
	@echo "Project data directories have been cleaned"

# Remove all unused Docker resources system-wide
prune:
	@echo "WARNING: This will remove ALL unused Docker resources system-wide"
	@echo "Press Enter to continue or Ctrl+C to cancel..."
	@read
	docker system prune

# Rebuild everything
re: fclean all

# List all services status
status:
	@echo "Docker containers status:"
	@docker ps -a
	@echo "\nDocker volumes:"
	@if docker volume ls | grep -q inception; then \
		docker volume ls | grep inception; \
	else \
		echo "No inception volumes found"; \
	fi
	@echo "\nDocker networks:"
	@if docker network ls | grep -q inception; then \
		docker network ls | grep inception; \
	else \
		echo "No inception networks found"; \
	fi

.PHONY: all hosts_config backup_dirs up down clean fclean re status

