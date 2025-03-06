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
		@echo -e "$(YELLOW)Adding $(DOMAIN_NAME) to /etc/hosts (may require password)$(RESET)"; \
		sudo sh -c 'echo "127.0.0.1 $(DOMAIN_NAME)" >> /etc/hosts'; \
		sudo sh -c 'echo "127.0.0.1 www.$(DOMAIN_NAME)" >> /etc/hosts'; \
	fi

# Create required directories
host_backup_dirs:
	@echo -e "$(BLUE)Creating data directories...$(RESET)"
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb

# Build and start containers
up: host_backup_dirs
	@echo -e "$(GREEN)Building and starting containers...$(RESET)"
#-d : only gives you an access to the terminal while it is runniing. so all the logs will be hidden😂 
# It starts the container in the background and returns control to your terminal. That is all what it does. 

	@docker compose -f $(DOCKER_COMPOSE_FILE) up -d --build
	@echo -e "$(GREEN)$(BOLD)Inception is now running!$(RESET)"
	@echo -e "$(GREEN)Access your website at https://$(DOMAIN_NAME)$(RESET)"

# Stop containers
down:
	@echo -e "$(YELLOW)Stopping containers...$(RESET)"
	@docker compose -f $(DOCKER_COMPOSE_FILE) down
	@echo -e "$(YELLOW)Containers stopped.$(RESET)"

# Remove containers, networks and images used by services
clean:
	@echo -e "$(RED)Cleaning up Docker resources...$(RESET)"
	@docker compose -f $(DOCKER_COMPOSE_FILE) down --volumes --rmi all
	@echo -e "$(RED)Docker resources cleaned.$(RESET)"

# Full cleanup including directories
fclean: clean
	@echo -e "$(RED)$(BOLD)Full cleanup in progress...$(RESET)"
#	@docker rm -f mariadb wordpress nginx 2>/dev/null || true
#	@docker rm -f inception_mariadb inception_wordpress inception_nginx 2>/dev/null || true
#	@docker rm -f srcs_mariadb srcs_wordpress srcs_nginx 2>/dev/null || true
	@sudo rm -rf $(DATA_PATH)/wordpress/*
	@sudo rm -rf $(DATA_PATH)/mariadb/*
	@echo -e "$(RED)$(BOLD)Project data directories have been cleaned.$(RESET)"

# Rebuild everything
re: fclean all

# List all services status
status:
	@echo -e "$(CYAN)$(BOLD)Docker containers status:$(RESET)"
	@docker ps -a
	@echo -e "\n$(CYAN)$(BOLD)Docker volumes:$(RESET)"
	@docker volume ls | grep srcs || echo "$(YELLOW)No project volumes found.$(RESET)"
	@echo -e "\n$(CYAN)$(BOLD)Docker networks:$(RESET)"
	@docker network ls | grep srcs || echo "$(YELLOW)No project networks found.$(RESET)"

# View logs of all services or specific service
logs:
	@echo -e "$(CYAN)Showing logs... (Ctrl+C to exit)$(RESET)"
	@if [ -z "$(filter-out logs,$(MAKECMDGOALS))" ]; then \
		docker compose -f $(DOCKER_COMPOSE_FILE) logs -f; \
	else \
		docker compose -f $(DOCKER_COMPOSE_FILE) logs -f $(filter-out logs,$(MAKECMDGOALS)); \
	fi

# Add these targets to make them available as arguments
nginx:
	@:

wordpress:
	@:

mariadb:

# Help command
help:
	@echo -e "$(BOLD)$(UNDERLINE)Inception Project Commands:$(RESET)"
	@echo -e "$(BOLD)make$(RESET)              : Set up and start the project"
	@echo -e "$(BOLD)make up$(RESET)           : Start containers"
	@echo -e "$(BOLD)make down$(RESET)         : Stop containers"
	@echo -e "$(BOLD)make clean$(RESET)        : Remove all Docker resources for this project"
	@echo -e "$(BOLD)make fclean$(RESET)       : Complete cleanup including data directories"
	@echo -e "$(BOLD)make re$(RESET)           : Rebuild the entire project"
	@echo -e "$(BOLD)make status$(RESET)       : Show status of containers, volumes, and networks"
	@echo -e "$(BOLD)make help$(RESET)         : Show this help message"

.PHONY: all hosts_config host_backup_dirs up down clean fclean re status help logs
