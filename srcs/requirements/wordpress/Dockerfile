FROM debian:buster

RUN apt-get update && apt-get install -y \
    php7.3-fpm \
    php7.3-mysql \
    wget \
    unzip

# WordPress 설치
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    rm latest.zip

COPY conf/www.conf /etc/php/7.3/fpm/pool.d/
COPY tools/wp-config.php /var/www/html/wordpress/

RUN chown -R www-data:www-data /var/www/html/wordpress

EXPOSE 9000

CMD ["php-fpm7.3", "-F"] 