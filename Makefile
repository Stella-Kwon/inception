NAME = inception

all: prepare $(NAME)

prepare:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb

$(NAME):
	@docker-compose -f srcs/docker-compose.yml up -d --build

clean:
	@docker-compose -f srcs/docker-compose.yml down

fclean: clean
	@docker system prune -a
	@sudo rm -rf /home/$(USER)/data/wordpress/*
	@sudo rm -rf /home/$(USER)/data/mariadb/*

re: fclean all

.PHONY: all clean fclean re prepare
