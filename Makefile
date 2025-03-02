# Makefile for Inception Project

# Variables
DOCKER_COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = ~/data
DOMAIN_NAME = $(USER).42.fr

# Color codes
RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
BLUE = \033[34m
PURPLE = \033[35m
CYAN = \033[36m
WHITE = \033[37m
RESET = \033[0m
BOLD = \033[1m
UNDERLINE = \033[4m

all: hosts_config host_backup_dirs up

# Set up hosts file (requires sudo)
hosts_config:
	@if ! grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		echo "$(YELLOW)Adding $(DOMAIN_NAME) to /etc/hosts (may require password)$(RESET)"; \
		sudo sh -c 'echo "127.0.0.1 $(DOMAIN_NAME)" >> /etc/hosts'; \
		sudo sh -c 'echo "127.0.0.1 www.$(DOMAIN_NAME)" >> /etc/hosts'; \
	fi

# Create required directories
host_backup_dirs:
	@echo "$(BLUE)Creating data directories...$(RESET)"
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb

# Build and start containers
up: host_backup_dirs
	@echo "$(GREEN)Building and starting containers...$(RESET)"
	@docker compose -f $(DOCKER_COMPOSE_FILE) up -d --build
	@echo "$(GREEN)$(BOLD)Inception is now running!$(RESET)"
	@echo "$(GREEN)Access your website at https://$(DOMAIN_NAME)$(RESET)"

# Stop containers
down:
	@echo "$(YELLOW)Stopping containers...$(RESET)"
	@docker compose -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(YELLOW)Containers stopped.$(RESET)"

# Remove containers, networks and images used by services
clean:
	@echo "$(RED)Cleaning up Docker resources...$(RESET)"
	@docker compose -f $(DOCKER_COMPOSE_FILE) down --volumes --rmi all
	@echo "$(RED)Docker resources cleaned.$(RESET)"

# Full cleanup including directories
fclean: clean
	@echo "$(RED)$(BOLD)Full cleanup in progress...$(RESET)"
#	@docker rm -f mariadb wordpress nginx 2>/dev/null || true
#	@docker rm -f inception_mariadb inception_wordpress inception_nginx 2>/dev/null || true
#	@docker rm -f srcs_mariadb srcs_wordpress srcs_nginx 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH)/wordpress/*
	@sudo rm -rf $(DATA_PATH)/mariadb/*
	@echo "$(RED)$(BOLD)Project data directories have been cleaned.$(RESET)"

# Rebuild everything
re: fclean all

# List all services status
status:
	@echo "$(CYAN)$(BOLD)Docker containers status:$(RESET)"
	@docker ps -a
	@echo "\n$(CYAN)$(BOLD)Docker volumes:$(RESET)"
	@docker volume ls | grep srcs || echo "$(YELLOW)No project volumes found.$(RESET)"
	@echo "\n$(CYAN)$(BOLD)Docker networks:$(RESET)"
	@docker network ls | grep srcs || echo "$(YELLOW)No project networks found.$(RESET)"

# Help command
help:
	@echo "$(BOLD)$(UNDERLINE)Inception Project Commands:$(RESET)"
	@echo "$(BOLD)make$(RESET)              : Set up and start the project"
	@echo "$(BOLD)make up$(RESET)           : Start containers"
	@echo "$(BOLD)make down$(RESET)         : Stop containers"
	@echo "$(BOLD)make clean$(RESET)        : Remove all Docker resources for this project"
	@echo "$(BOLD)make fclean$(RESET)       : Complete cleanup including data directories"
	@echo "$(BOLD)make re$(RESET)           : Rebuild the entire project"
	@echo "$(BOLD)make status$(RESET)       : Show status of containers, volumes, and networks"
	@echo "$(BOLD)make help$(RESET)         : Show this help message"

.PHONY: all hosts_config host_backup_dirs up down clean fclean re status help
